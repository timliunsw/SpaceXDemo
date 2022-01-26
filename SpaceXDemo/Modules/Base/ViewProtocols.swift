//
//  ViewProtocols.swift
//  SpaceXDemo
//
//  Created by Tim Li on 26/1/22.
//

import UIKit
import RxSwift
import RxCocoa

// MARK: - ActivityIndicatable
protocol ActivityIndicatable {
    var activityIndicator: UIActivityIndicatorView { get }
}

// MARK: - DisposeBagManagedObserver
protocol DisposeBagManagedObserver {
    var bag: DisposeBag { get }
}

// MARK: - LoadingStatusEmitable
protocol LoadingStatusEmitable {
    var isLoadingDriver: Driver<Bool> { get }
}

// MARK: - LoadingStatusObserver
protocol LoadingStatusObserver: AnyObject, DisposeBagManagedObserver {
    var loadingStatusEmitable: LoadingStatusEmitable { get }
    func bindLoadingStatus()
}

extension LoadingStatusObserver where Self: UIViewController & ActivityIndicatable {
    func bindLoadingStatus() {
        loadingStatusEmitable.isLoadingDriver
            .map { !$0 }
            .drive(activityIndicator.rx.isHidden)
            .disposed(by: bag)
    }
}
