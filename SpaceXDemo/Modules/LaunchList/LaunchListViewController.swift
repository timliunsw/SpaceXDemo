//
//  LaunchListViewController.swift
//  SpaceXDemo
//
//  Created by Tim Li on 15/9/21.
//

import UIKit
import RxSwift
import RxDataSources
import SafariServices

class LaunchListViewController: BaseViewController {
    typealias DataSource = RxTableViewSectionedReloadDataSource<LaunchSection>
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.cellId)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .secondarySystemBackground
        tableView.accessibilityIdentifier = Constants.accessibilityIdentifier
        
        return tableView
    }()
    
    private let refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        
        return control
    }()
    
    var viewModel: LaunchListViewModel!
    
    static func newInstance() -> LaunchListViewController {
        let vc = LaunchListViewController()
        vc.viewModel = LaunchListViewModel()
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        bindViews()
    }
}

// MARK: - Layout
private extension LaunchListViewController {
    func setupView() {
        view.backgroundColor = .systemBackground
        
        setupNavigationItem()
        setupTableView()
        setupActivityIndicator()
    }
    
    func setupNavigationItem() {
        navigationItem.title = "Nav.Title.Launch".localized
        let filter = UIBarButtonItem(title: "Filter".localized, style: .plain, target: self, action: #selector(filterAlert))
        let sort = UIBarButtonItem(title: "Sort".localized, style: .plain, target: self, action: #selector(sortAlert))
        let reset = UIBarButtonItem(title: "Reset".localized, style: .plain, target: self, action: #selector(resetLaunches))
        navigationItem.rightBarButtonItems = [filter, sort, reset]
    }
    
    func setupTableView() {
        view.addSubview(tableView)
        tableView.constraintsToSuperview()
        tableView.refreshControl = refreshControl
    }
}

// MARK: - LoadingStatusObserver
extension LaunchListViewController: LoadingStatusObserver {
    var loadingStatusEmitable: LoadingStatusEmitable {
        viewModel
    }
}

// MARK: - Reactive
private extension LaunchListViewController {
    func bindViews() {
        bindLoadingStatus()
        
        refreshControl.rx
            .controlEvent(UIControl.Event.valueChanged)
            .subscribe(onNext: { [weak self] in
                guard let self = self else {
                    return
                }
                
                self.viewModel.fetchLaunches()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.refreshControl.endRefreshing()
                }
            })
            .disposed(by: bag)
        
        let dataSource = DataSource(
            configureCell: { (_, tableView, indexPath, model) in
                let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellId)!
                cell.selectionStyle = .none
                cell.accessoryType = .detailButton
                cell.textLabel?.text = "No.\(model.flightNumber), \(model.missionName) (\(model.launchYear))"
                cell.imageView?.image = UIImage(systemName: model.launchSuccess ? "checkmark.seal.fill" : "xmark.seal.fill")
                cell.imageView?.tintColor = model.launchSuccess ? #colorLiteral(red: 0, green: 1, blue: 0.8470588235, alpha: 0.85) : #colorLiteral(red: 1, green: 0.2117647059, blue: 0, alpha: 0.8470588235)
                cell.accessibilityIdentifier = "No.\(model.flightNumber)"
                return cell
            },
            titleForHeaderInSection: { dataSource, index in
                if dataSource[index].header == " " {
                    return nil
                }
                return dataSource[index].header
            }
        )
        
        viewModel.launchesObservable
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        
        tableView.rx
            .modelSelected(Launch.self)
            .map{ $0.flightNumber }
            .subscribe(onNext: { [weak self] flightNumber in
                guard let self = self else {
                    return
                }
                
                DispatchQueue.main.async {
                    let viewModel = DetailsViewModel(flightNumber: flightNumber)
                    let detailsVC = DetailsViewController.newInstance(with: viewModel)
                    
                    self.navigationController?.pushViewController(detailsVC, animated: true)
                }
            }).disposed(by: bag)
        
        tableView.rx
            .itemAccessoryButtonTapped
            .subscribe(onNext: { [weak self] indexPath in
                guard
                    let self = self,
                    let url = URL(string: self.viewModel.launches.value[indexPath.row].links.wikipedia),
                    UIApplication.shared.canOpenURL(url)
                else {
                    return
                }
                
                DispatchQueue.main.async {
                    self.present(SFSafariViewController(url: url), animated: true)
                }
            })
            .disposed(by: bag)
        
        viewModel.notifyError
            .asDriver()
            .drive(onNext: { [weak self] error in
                guard
                    let self = self,
                    let error = error
                else {
                    return
                }
                
                DispatchQueue.main.async {
                    self.showAlert(error.localizedDescription)
                }
            })
            .disposed(by: bag)
    }
}

// MARK: - Sort/filter popup
extension LaunchListViewController {
    @objc private func sortAlert() {
        let alert = UIAlertController(title: "Sort.Alert.Title".localized, message: "Sort.Alert.Message".localized, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Sort.Alert.Option.Date".localized, style: .default , handler: { [weak self] (UIAlertAction) in
            guard let self = self else {
                return
            }
            
            self.viewModel.launchesSortedByDate()
        }))
        
        alert.addAction(UIAlertAction(title: "Sort.Alert.Option.Mission".localized, style: .default , handler: { [weak self] (UIAlertAction) in
            guard let self = self else {
                return
            }
            
            self.viewModel.launchesSortedByMissionName()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel , handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc private func filterAlert() {
        let alert = UIAlertController(title: "Filter.Alert.Title".localized, message: "Filter.Alert.Message".localized, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Filter.Alert.Option.Success".localized, style: .default , handler: { [weak self] (UIAlertAction) in
            guard let self = self else {
                return
            }
            
            self.viewModel.filterLaunchesBy(status: true)
        }))
        
        alert.addAction(UIAlertAction(title: "Filter.Alert.Option.Failure".localized, style: .default , handler: { [weak self] (UIAlertAction) in
            guard let self = self else {
                return
            }
            
            self.viewModel.filterLaunchesBy(status: false)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel , handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc private func resetLaunches() {
        viewModel.resetLaunches()
    }
}
