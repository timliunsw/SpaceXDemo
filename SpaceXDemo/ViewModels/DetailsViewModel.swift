//
//  DetailsViewModel.swift
//  SpaceXDemo
//
//  Created by Tim Li on 16/9/21.
//

import Foundation
import RxSwift
import RxCocoa

protocol DetailsViewModelProtocol {
    var flightNumber: Int { get }
    var launch: BehaviorRelay<Launch?> { get }
    var rocket: BehaviorRelay<Rocket?> { get }
    var launchText: BehaviorRelay<String> { get }
    var rocketText: BehaviorRelay<String> { get }
    var notifyError: BehaviorRelay<NetworkError?> { get }
    
    func fetchDetails()
    func fetchRocket(withRocketId rocketId: String)
    func generateDetailsContent(with launch: Launch, and rocket: Rocket) -> (String, String)
}

class DetailsViewModel: DetailsViewModelProtocol {
    var flightNumber: Int = 0
    var launch: BehaviorRelay<Launch?> = BehaviorRelay<Launch?>(value: nil)
    var rocket: BehaviorRelay<Rocket?> = BehaviorRelay<Rocket?>(value: nil)
    var launchText = BehaviorRelay<String>(value: "")
    var rocketText = BehaviorRelay<String>(value: "")
    var notifyError: BehaviorRelay<NetworkError?> = BehaviorRelay(value: nil)
    var apiService: APIServiceProtocol!
    
    private let bag = DisposeBag()
    
    init(apiService: APIServiceProtocol = APIService.shared, flightNumber: Int) {
        self.flightNumber = flightNumber
        self.apiService = apiService
        
        setupReactive()
        fetchDetails()
    }
}

// MARK: Reactive
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

// MARK: Handle data
extension DetailsViewModel {
    func fetchDetails() {
        apiService.fetchLaunch(withFlightNumber: flightNumber) { [weak self] result in
            guard let self = self else {
                return
            }
            
            if case .success(let launch) = result {
                self.launch.accept(launch)
                let rocketId = launch.rocket.id
                self.fetchRocket(withRocketId: rocketId)
            } else if case .failure(let error) = result {
                self.notifyError.accept(error)
                self.launch.accept(nil)
                self.rocket.accept(nil)
            }
        }
    }
    
    func fetchRocket(withRocketId rocketId: String) {
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

