//
//  MainViewController.swift
//  SpaceXDemo
//
//  Created by Tim Li on 15/9/21.
//

import UIKit
import RxSwift
import RxDataSources
import SafariServices

struct LaunchSection {
    var header: String
    var items: [Item]
}

extension LaunchSection: SectionModelType {
    typealias Item = Launch
    
    init(original: LaunchSection, items: [Item]) {
        self = original
        self.items = items
    }
}

class MainViewController: UIViewController {
    typealias DataSource = RxTableViewSectionedReloadDataSource<LaunchSection>
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.cellId)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .clear
        
        return tableView
    }()
    
    private let refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        
        return control
    }()
    
    private let bag = DisposeBag()
    private var viewModel: MainViewModel!
    
    static func newInstance() -> MainViewController {
        let vc = MainViewController()
        vc.viewModel = MainViewModel()
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        bindViews()
    }
}

// MARK: Layout
private extension MainViewController {
    func setupView() {
        view.backgroundColor = .systemBackground
        
        setupNavigationItem()
        setupTableView()
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

// MARK: Reactive
private extension MainViewController {
    func bindViews() {
        refreshControl.rx
            .controlEvent(UIControl.Event.valueChanged)
            .subscribe(onNext: { [weak self] in
                guard let self = self else {
                    return
                }
                
                self.viewModel.fetchLaunches() {
                    DispatchQueue.main.async {
                        self.refreshControl.endRefreshing()
                    }
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
                
                let viewModel = DetailsViewModel(flightNumber: flightNumber)
                let detailsVC = DetailsViewController.newInstance(with: viewModel)
                
                self.navigationController?.pushViewController(detailsVC, animated: true)
            }).disposed(by: bag)
        
        tableView.rx
            .itemAccessoryButtonTapped
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else {
                    return
                }
                
                let launch = self.viewModel.launches.value[indexPath.row]
                guard
                    let url = URL(string: launch.links.wikipedia),
                    UIApplication.shared.canOpenURL(url)
                else {
                    return
                }
                
                self.present(SFSafariViewController(url: url), animated: true)
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
                
                self.showAlert(error.localizedDescription)
            })
            .disposed(by: bag)
    }
}

// MARK: sort and filter
extension MainViewController {
    @objc private func sortAlert() {
        let alert = UIAlertController(title: "Sort.Alert.Title".localized, message: "Sort.Alert.Message".localized, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Sort.Alert.Option.Date".localized, style: .default , handler:{ [weak self] (UIAlertAction) in
            guard let self = self else {
                return
            }
            self.viewModel.launchesSortedByDate()
        }))
        
        alert.addAction(UIAlertAction(title: "Sort.Alert.Option.Mission".localized, style: .default , handler:{ [weak self] (UIAlertAction) in
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
        
        alert.addAction(UIAlertAction(title: "Filter.Alert.Option.Success".localized, style: .default , handler:{ [weak self] (UIAlertAction) in
            guard let self = self else {
                return
            }
            self.viewModel.launchesFilteredBySuccess()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel , handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc private func resetLaunches() {
        viewModel.resetLaunches()
    }
}
