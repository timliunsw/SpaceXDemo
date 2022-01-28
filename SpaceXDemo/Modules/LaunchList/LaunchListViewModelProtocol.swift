//
//  LaunchListViewModelProtocol.swift
//  SpaceXDemo
//
//  Created by Tim Li on 27/1/22.
//

import RxCocoa
import RxDataSources

/// The protocol needs to be conformed to create launch list view model.
protocol LaunchListViewModelProtocol {
    /// A `Launch` array value type BehaviorRelay is used to be subscribed launches information.
    var launches: BehaviorRelay<[Launch]> { get }
    
    /// A `LaunchSection` array value type BehaviorRelay is used to be subscribed
    /// launches information in launch section data source type.
    var launchesObservable: BehaviorRelay<[LaunchSection]> { get }
    
    /// A NetworkError value type BehaviorRelay is used to be subscribed the error status.
    var notifyError: BehaviorRelay<NetworkError?> { get }
    
    /**
     Fetch launches data.
     
     - parameter completion: A block that's called after requested launches data is retireved.
     */
    func fetchLaunches(completion: (() -> Void)?)
    
    /**
     Sort launches infomation by the launch date.
     */
    func launchesSortedByDate()
    
    /**
     Sort launches infomation by the first alphabet.
     */
    func launchesSortedByMissionName()
    
    /**
     Filter observable launches infomation according to the status of launches.
     
     - parameter isSuccess: The status of launches.
     If the launch was successful, pass it as `true`.
     Otherwise, pass it as `false` instead.
     */
    func filterLaunchesBy(status isSuccess: Bool)
    
    /**
     Reset observable launches infomation.
     */
    func resetLaunches()
}


/// The model for launch section, which conforms SectionModelType.
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
