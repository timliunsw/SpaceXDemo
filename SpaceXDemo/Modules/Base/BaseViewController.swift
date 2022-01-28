//
//  BaseViewController.swift
//  SpaceXDemo
//
//  Created by Tim Li on 26/1/22.
//

import UIKit
import RxSwift

/**
 Base view controller for all view controllers.
 It is configured with shared variables and presentation logical functions.
 */
class BaseViewController: UIViewController, DisposeBagManagedObserver {
    let bag = DisposeBag()

    var activityIndicator: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView()
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        indicatorView.style = .large
        indicatorView.startAnimating()
        
        return indicatorView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - ActivityIndicatable
extension BaseViewController: ActivityIndicatable {
    /// Add activity indicator to view
    func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
