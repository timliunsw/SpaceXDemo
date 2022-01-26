//
//  BaseViewModel.swift
//  SpaceXDemo
//
//  Created by Tim Li on 27/1/22.
//

import Foundation
import RxSwift
import RxCocoa

class BaseViewModel: LoadingStatusEmitable {
    let isLoading: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var notifyError: BehaviorRelay<NetworkError?> = BehaviorRelay(value: nil)
    var apiService: APIServiceProtocol!
    let bag = DisposeBag()
    
    var isLoadingDriver: Driver<Bool> {
        return isLoading.asDriver()
    }
}
