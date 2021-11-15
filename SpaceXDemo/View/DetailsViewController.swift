//
//  DetailsViewController.swift
//  SpaceXDemo
//
//  Created by Tim Li on 15/9/21.
//

import UIKit
import RxSwift
import RxCocoa

class DetailsViewController: UIViewController {

    private let detailsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        return stackView
    }()
    
    private let launchLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .label
        label.backgroundColor = .cyan
        label.sizeToFit()
        
        return label
    }()
    
    private let rocketLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .label
        label.backgroundColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
        label.sizeToFit()
        
        return label
    }()
    
    private let bag = DisposeBag()
    private var viewModel: DetailsViewModel!
    
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

// MARK: Layout
private extension DetailsViewController {
    func setupView() {
        navigationItem.title = "Nav.Title.Details".localized
        view.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        view.addSubview(detailsStackView)
        
        detailsStackView.addArrangedSubview(launchLabel)
        detailsStackView.addArrangedSubview(rocketLabel)
        
        NSLayoutConstraint.activate([
            detailsStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            detailsStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            detailsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            detailsStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
        ])
    }
}

// MARK: Reactive
private extension DetailsViewController {
    func bindViews() {
        viewModel.launchText.asObservable()
            .bind(to:self.launchLabel.rx.text)
            .disposed(by: bag)
        
        viewModel.rocketText.asObservable()
            .bind(to:self.rocketLabel.rx.text)
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
