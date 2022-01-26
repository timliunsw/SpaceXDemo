//
//  DetailsViewModelProtocol.swift
//  SpaceXDemo
//
//  Created by Tim Li on 27/1/22.
//

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
