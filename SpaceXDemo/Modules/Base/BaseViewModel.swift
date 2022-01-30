//
//  BaseViewModel.swift
//  SpaceXDemo
//
//  Created by Tim Li on 27/1/22.
//

import Foundation
import RxSwift
import RxCocoa

/**
 Base view model for all view models.
 It is configured with shared variables and business logical functions.
 */
class BaseViewModel: DisposeBagManagedObserver, LoadingStatusEmitable {
    
    /// A boolean value type BehaviorRelay is used to be subscribed the loading status.
    /// It is `false` by default.
    let isLoading: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    /// A NetworkError value type BehaviorRelay is used to be subscribed the error status.
    /// It is `NULL` by default.
    var notifyError: BehaviorRelay<NetworkError?> = BehaviorRelay(value: nil)
    
    /// A  manager used for handling API service.
    var apiService: APIServiceProtocol!
    
    let bag = DisposeBag()
    
    var isLoadingDriver: Driver<Bool> {
        return isLoading.asDriver()
    }
}
