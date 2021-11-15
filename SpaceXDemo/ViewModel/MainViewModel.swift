//
//  MainViewModel.swift
//  SpaceXDemo
//
//  Created by Tim Li on 15/9/21.
//

import Foundation
import RxSwift
import RxCocoa

protocol MainViewModelProtocol {
    var launches: BehaviorRelay<[Launch]> { get }
    var launchesObservable: BehaviorRelay<[LaunchSection]> { get }
    var filteredLaunches: BehaviorRelay<[LaunchSection]> { get }
    var notifyError: BehaviorRelay<NetworkError?> { get }
    
    func fetchLaunches(completion: (() -> Void)?)
    func launchesSortedByDate()
    func launchesSortedByMissionName()
    func launchesFilteredBySuccess()
    func resetLaunches()
}

class MainViewModel: MainViewModelProtocol {
    var launches: BehaviorRelay<[Launch]> = BehaviorRelay(value: [])
    var launchesObservable: BehaviorRelay<[LaunchSection]> = BehaviorRelay(value: [])
    var filteredLaunches: BehaviorRelay<[LaunchSection]> = BehaviorRelay(value: [])
    var notifyError: BehaviorRelay<NetworkError?> = BehaviorRelay(value: nil)
    
    private let bag = DisposeBag()
    
    init() {
        setupReactive()
        fetchLaunches()
    }
}

// MARK: Reactive
private extension MainViewModel {
    func setupReactive() {
        launches.asObservable()
            .subscribe(onNext: { [weak self] launches in
                guard let self = self else {
                    return
                }
                var sections: [LaunchSection] = []
                
                launches.forEach({ launch in
                    let header: String = " "
                    let section = LaunchSection(header: header, items: [launch])
                    sections.append(section)
                })
                
                self.launchesObservable.accept(sections)
                self.setFilteredLaunches(with: launches)
            })
            .disposed(by: bag)
    }
}

// MARK: Handle data
extension MainViewModel {
    func fetchLaunches(completion: (() -> Void)? = nil) {
        APIService.shared.fetchLaunches() { [weak self] result in
            guard let self = self else {
                completion?()
                return
            }
            
            switch result {
                case .success(let data):
                    self.launches.accept(data)
                case .failure(let error):
                    self.notifyError.accept(error)
            }
            
            completion?()
        }
    }
    
    func launchesSortedByDate() {
        _ = Observable.just(launches.value)
            .map {
                $0.sorted(by: { $0.launchDate < $1.launchDate })
            }
            .subscribe(onNext: { [weak self] launches in
                guard let self = self else {
                    return
                }
                var sections: [LaunchSection] = []
                
                launches.forEach({ launch in
                    let header: String = "\(launch.launchYear)"
                    if let index = sections.firstIndex(where: { $0.header == header }) {
                        sections[index].items.append(launch)
                    } else {
                        let section = LaunchSection(header: header, items: [launch])
                        sections.append(section)
                    }
                })
                
                self.launchesObservable.accept(sections)
            })
            .disposed(by: bag)
    }
    
    func launchesSortedByMissionName() {
        _ = Observable.just(launches.value)
        .map {
            $0.sorted(by: { $0.missionName < $1.missionName })
        }
        .subscribe(onNext: { [weak self] launches in
            guard let self = self else {
                return
            }
            var sections: [LaunchSection] = []
            
            launches.forEach({ launch in
                let header: String = "\(launch.missionName.first ?? " ")".uppercased()
                if let index = sections.firstIndex(where: { $0.header == header }) {
                    sections[index].items.append(launch)
                } else {
                    let section = LaunchSection(header: header, items: [launch])
                    sections.append(section)
                }
            })
            
            self.launchesObservable.accept(sections)
        })
        .disposed(by: bag)
    }
    
    func launchesFilteredBySuccess() {
        launchesObservable.accept(filteredLaunches.value)
    }
    
    func resetLaunches() {
        fetchLaunches()
    }
    
    private func setFilteredLaunches(with launches: [Launch]) {
        let successedLaunches = launches.filter { $0.launchSuccess }
        var sortedSections: [LaunchSection] = []
        successedLaunches.forEach({ launch in
            let header: String = " "
            let section = LaunchSection(header: header, items: [launch])
            sortedSections.append(section)
        })
        
        self.filteredLaunches.accept(sortedSections)
    }
}
