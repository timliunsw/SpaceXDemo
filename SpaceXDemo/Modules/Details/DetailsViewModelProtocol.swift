//
//  DetailsViewModelProtocol.swift
//  SpaceXDemo
//
//  Created by Tim Li on 27/1/22.
//

import RxCocoa

/**
 The protocol needs to be conformed to create details view model.
 */
protocol DetailsViewModelProtocol {
    /// The flight number of the specified launch.
    var flightNumber: Int { get }
    
    /// An optional `Launch` value type BehaviorRelay is used to be subscribed launch information.
    var launch: BehaviorRelay<Launch?> { get }
    
    /// An optional `Rocket` value type BehaviorRelay is used to be subscribed rocket information.
    var rocket: BehaviorRelay<Rocket?> { get }
    
    /// A `String` value type BehaviorRelay is used to be subscribed launch information to be presented.
    var launchText: BehaviorRelay<String> { get }
    
    /// A `String` value type BehaviorRelay is used to be subscribed rocket information to be presented.
    var rocketText: BehaviorRelay<String> { get }
    
    /// A NetworkError value type BehaviorRelay is used to be subscribed the error status.
    var notifyError: BehaviorRelay<NetworkError?> { get }
    
    /**
     Fetch specified launch information.
     */
    func fetchDetails()
    
    /**
     Fetch specified rocket information.
     
     - parameter rocketId: Id of the rocket.
     */
    func fetchRocket(withRocketId rocketId: String)
    
    /**
     Generate launch information to be presented and rocket information to be presented based on
     specified launch information and specified rocket information.
     
     - parameter launch: The specified launch information.
     - parameter rocket: The specified rocket information.
     
     - returns: A tuple with launch information to be presented and rocket information to be presented.
     */
    func generateDetailsContent(with launch: Launch, and rocket: Rocket) -> (String, String)
}
