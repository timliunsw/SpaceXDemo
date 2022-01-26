//
//  LaunchListViewModel.swift
//  SpaceXDemo
//
//  Created by Tim Li on 15/9/21.
//

import Foundation
import RxSwift
import RxCocoa

class LaunchListViewModel: BaseViewModel, LaunchListViewModelProtocol {
    var launches: BehaviorRelay<[Launch]> = BehaviorRelay(value: [])
    var launchesObservable: BehaviorRelay<[LaunchSection]> = BehaviorRelay(value: [])
    
    init(apiService: APIServiceProtocol = APIService.shared) {
        super.init()
        self.apiService = apiService
        
        setupReactive()
        fetchLaunches()
    }
}

// MARK: - Reactive
private extension LaunchListViewModel {
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
            })
            .disposed(by: bag)
    }
}

// MARK: - Handle data
extension LaunchListViewModel {
    func fetchLaunches(completion: (() -> Void)? = nil) {
        isLoading.accept(true)
        apiService.fetchLaunches() { [weak self] result in
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
            
            self.isLoading.accept(false)
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
    
    func filterLaunchesBy(status isSuccess: Bool) {
        _ = Observable.just(launches.value)
            .map {
                $0.filter { $0.launchSuccess == isSuccess }
            }
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
            })
            .disposed(by: bag)
    }
    
    func resetLaunches() {
        var sections: [LaunchSection] = []
        launches.value
            .forEach({ launch in
                let header: String = " "
                let section = LaunchSection(header: header, items: [launch])
                sections.append(section)
            })
        launchesObservable.accept(sections)
    }
}
