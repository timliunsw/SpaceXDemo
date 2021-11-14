//
//  DetailsViewModel.swift
//  SpaceXDemo
//
//  Created by Tim Li on 16/9/21.
//

import Foundation
import RxSwift
import RxCocoa

class DetailsViewModel {
    var flightNumber: Int = 0
    let launch: BehaviorRelay<Launch?> = BehaviorRelay<Launch?>(value: nil)
    let rocket: BehaviorRelay<Rocket?> = BehaviorRelay<Rocket?>(value: nil)
    let launchText = BehaviorRelay<String>(value: "")
    let rocketText = BehaviorRelay<String>(value: "")
    private let bag = DisposeBag()
    
    init(flightNumber: Int) {
        self.flightNumber = flightNumber
        
        setupReactive()
        fetchDetails()
    }
}

// MARK: Handle data
private extension DetailsViewModel {
    func fetchDetails() {
        APIService.shared.fetchLaunch(withFlightNumber: flightNumber) { [weak self] launch in
            guard let self = self else {
                return
            }
            
            if case .success(let launch) = launch {
                let rocketId = launch.rocket.id
                
                APIService.shared.fetchRocket(withRocketId: rocketId) { [weak self] rocket  in
                    guard let self = self else {
                        return
                    }
                    
                    if case .success(let rocket) = rocket {
                        self.launch.accept(launch)
                        self.rocket.accept(rocket)
                    }
                }
            }
        }
    }
    
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
    
    func generateDetailsContent(with launch: Launch, and rocket: Rocket) -> (String, String) {
        let successOrFail = launch.launchSuccess ? "Launch.Success".localized : "Launch.Fail".localized
        let launchContent = "Launch Info\n\nLaunch mission \(launch.missionName) in \(launch.launchYear) \(successOrFail)\n\n\(launch.details)"
        
        guard
            let company = rocket.company,
            let country = rocket.country,
            let dec = rocket.description
        else {
            return (launchContent, "")
        }
        
        let rocketContent = "Rocket Details\n\nThe rocket \(rocket.name)'s type is \(rocket.type), and it belongs to \(company) in \(country).\n\n\(dec)"
        return (launchContent, rocketContent)
    }
}

