//
//  LaunchListViewModelProtocol.swift
//  SpaceXDemo
//
//  Created by Tim Li on 27/1/22.
//

import RxCocoa
import RxDataSources

protocol LaunchListViewModelProtocol {
    var launches: BehaviorRelay<[Launch]> { get }
    var launchesObservable: BehaviorRelay<[LaunchSection]> { get }
    var notifyError: BehaviorRelay<NetworkError?> { get }
    
    func fetchLaunches(completion: (() -> Void)?)
    func launchesSortedByDate()
    func launchesSortedByMissionName()
    func filterLaunchesBy(status isSuccess: Bool)
    func resetLaunches()
}


struct LaunchSection {
    var header: String
    var items: [Item]
}

extension LaunchSection: SectionModelType {
    typealias Item = Launch
    
    init(original: LaunchSection, items: [Item]) {
        self = original
        self.items = items
    }
}
