//
//  API.swift
//  SpaceXDemo
//
//  Created by Tim Li on 26/1/22.
//

import Foundation

typealias LaunchesDataTaskResult = (Result<[Launch], NetworkError>) -> Void
typealias LaunchDataTaskResult = (Result<Launch, NetworkError>) -> Void
typealias RocketDataTaskResult = (Result<Rocket, NetworkError>) -> Void

protocol APIServiceProtocol {
    func fetchLaunches(completion: @escaping LaunchesDataTaskResult)
    func fetchLaunch(withFlightNumber number: Int, completion: @escaping LaunchDataTaskResult)
    func fetchRocket(withRocketId id: String, completion: @escaping RocketDataTaskResult)
}
