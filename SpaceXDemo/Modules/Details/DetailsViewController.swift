//
//  DetailsViewController.swift
//  SpaceXDemo
//
//  Created by Tim Li on 15/9/21.
//

import UIKit
import RxSwift
import RxCocoa

class DetailsViewController: BaseViewController {
    
    // Stack view for launch infomation and rocket infomation
    private let detailsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        return stackView
    }()
    
    // Launch infomation label
    private let launchLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .label
        label.backgroundColor = .cyan
        label.sizeToFit()
        label.minimumScaleFactor = 0.1
        
        return label
    }()
    
    // Rocket infomation label
    private let rocketLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .label
        label.backgroundColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
        label.sizeToFit()
        label.minimumScaleFactor = 0.1
        
        return label
    }()
    
    private var viewModel: DetailsViewModel!
    
    /**
     `DetailsViewController` initialization.
     
     - parameter viewModel: View model bind to the view controller.
     
     - returns: The instance of `DetailsViewController`.
     */
    static func newInstance(with viewModel: DetailsViewModel) -> DetailsViewController {
        let vc = DetailsViewController()
        vc.viewModel = viewModel
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        bindViews()
    }
}

// MARK: - LoadingStatusObserver
extension DetailsViewController: LoadingStatusObserver {
    var loadingStatusEmitable: LoadingStatusEmitable {
        viewModel
    }
}

// MARK: - Layout
private extension DetailsViewController {
    
    func setupView() {
        navigationItem.title = "Nav.Title.Details".localized
        view.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        view.addSubview(detailsStackView)
        
        detailsStackView.addArrangedSubview(launchLabel)
        detailsStackView.addArrangedSubview(rocketLabel)
        
        NSLayoutConstraint.activate([
            detailsStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            detailsStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            detailsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            detailsStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
        ])
        
        setupActivityIndicator()
    }
}

// MARK: - Reactive
private extension DetailsViewController {
    
    func bindViews() {
        bindLoadingStatus()
        
        // Bind launch information to be presented launch Label.
        viewModel.launchText
            .asObservable()
            .bind(to:self.launchLabel.rx.text)
            .disposed(by: bag)
        
        // Bind rocket information to be presented rocket Label.
        viewModel.rocketText
            .asObservable()
            .bind(to:self.rocketLabel.rx.text)
            .disposed(by: bag)
        
        // Subscribe the error BehaviorRelay
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
