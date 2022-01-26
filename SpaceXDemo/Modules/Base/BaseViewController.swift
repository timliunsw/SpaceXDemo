//
//  BaseViewController.swift
//  SpaceXDemo
//
//  Created by Tim Li on 26/1/22.
//

import UIKit
import RxSwift

class BaseViewController: UIViewController {
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
    func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
