//
//  ViewProtocols.swift
//  SpaceXDemo
//
//  Created by Tim Li on 26/1/22.
//

import UIKit
import RxSwift
import RxCocoa

/**
 The protocol needs to be conformed to show the activity indicator view,
 indicating the API request is in progress.
 */
protocol ActivityIndicatable {
    /// The activity indicator view which would be added to the superview.
    var activityIndicator: UIActivityIndicatorView { get }
}

/**
 The protocol needs to be conformed to manage disposable subscriptions.
 */
protocol DisposeBagManagedObserver {
    /// A bag holds disposables.
    /// Allows us not to have to dispose of each subscription individually.
    var bag: DisposeBag { get }
}

/**
 The protocol needs to be conformed to emit loading status.
 */
protocol LoadingStatusEmitable {
    /// A boolean value type driver is used to observe loading status.
    var isLoadingDriver: Driver<Bool> { get }
}

/**
 The protocol needs to be conformed to observe loading status.
 */
protocol LoadingStatusObserver: AnyObject, DisposeBagManagedObserver {
    /// An observable to emit loading status.
    var loadingStatusEmitable: LoadingStatusEmitable { get }
    
    /// Bind loading status
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
