//
//  DetailsViewModel.swift
//  SpaceXDemo
//
//  Created by Tim Li on 16/9/21.
//

import Foundation
import RxSwift
import RxCocoa

/**
 Details view model, which confirms `BaseViewModel` and `DetailsViewModelProtocol`.
 */
class DetailsViewModel: BaseViewModel, DetailsViewModelProtocol {
    var flightNumber: Int = 0
    var launch: BehaviorRelay<Launch?> = BehaviorRelay<Launch?>(value: nil)
    var rocket: BehaviorRelay<Rocket?> = BehaviorRelay<Rocket?>(value: nil)
    var launchText = BehaviorRelay<String>(value: "")
    var rocketText = BehaviorRelay<String>(value: "")
    
    /**
     `DetailsViewModel` initialization.
     
     - parameter apiService: A manager used for handling API service.
     It is `APIService.shared` by default.
     - parameter flightNumber: The flight number of the specified launch.
     */
    init(apiService: APIServiceProtocol = APIService.shared, flightNumber: Int) {
        super.init()
        self.flightNumber = flightNumber
        self.apiService = apiService
        
        setupReactive()
        fetchDetails()
    }
}

// MARK: - Reactive
private extension DetailsViewModel {
    
    func setupReactive() {
        Observable.combineLatest(launch.asObservable(),
                                 rocket.asObservable())
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (launch, rocket) in
                guard
                    let self = self,
                    let launch = launch,
                    let rocket = rocket
                else {
                    return
                }
                
                let content = self.generateDetailsContent(with: launch, and: rocket)
                self.launchText.accept(content.0)
                self.rocketText.accept(content.1)
                
            })
            .disposed(by: bag)
    }
}

// MARK: - Handle data
extension DetailsViewModel {
    
    func fetchDetails() {
        isLoading.accept(true)
        apiService.fetchLaunch(withFlightNumber: flightNumber) { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
                case .success(let launch):
                    self.launch.accept(launch)
                    let rocketId = launch.rocket.id
                    self.fetchRocket(withRocketId: rocketId)
                case .failure(let error):
                    self.notifyError.accept(error)
                    self.launch.accept(nil)
                    self.rocket.accept(nil)
            }
            
            self.isLoading.accept(false)
        }
    }
    
    func fetchRocket(withRocketId rocketId: String) {
        isLoading.accept(true)
        apiService.fetchRocket(withRocketId: rocketId) { [weak self] rocket in
            guard let self = self else {
                return
            }
            
            switch rocket {
                case .success(let rocket):
                    self.rocket.accept(rocket)
                case .failure(let error):
                    self.notifyError.accept(error)
                    self.rocket.accept(nil)
            }
            self.isLoading.accept(false)
        }
    }
    
    func generateDetailsContent(with launch: Launch, and rocket: Rocket) -> (String, String) {
        let successOrFail = launch.launchSuccess ? "Launch.Success".localized : "Launch.Fail".localized
        let launchContent = "Launch Info\nLaunch mission \(launch.missionName) in \(launch.launchYear) \(successOrFail)\n\(launch.details)"
        
        guard
            let company = rocket.company,
            let country = rocket.country,
            let dec = rocket.description
        else {
            return (launchContent, "")
        }
        
        let rocketContent = "Rocket Details\nThe rocket \(rocket.name)'s type is \(rocket.type), and it belongs to \(company) in \(country).\n\(dec)"
        return (launchContent, rocketContent)
    }
}

