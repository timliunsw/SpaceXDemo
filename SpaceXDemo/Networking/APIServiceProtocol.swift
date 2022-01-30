//
//  APIServiceProtocol.swift
//  SpaceXDemo
//
//  Created by Tim Li on 26/1/22.
//

import Foundation

/// Wrapper for completion block of fetching launches.
typealias LaunchesDataTaskResult = (Result<[Launch], NetworkError>) -> Void

/// Wrapper for completion block of fetching a specified launch.
typealias LaunchDataTaskResult = (Result<Launch, NetworkError>) -> Void

/// Wrapper for completion block of fetching a specified rocket.
typealias RocketDataTaskResult = (Result<Rocket, NetworkError>) -> Void

/**
 The protocol needs to be conformed to utilise API service .
 */
protocol APIServiceProtocol {
    
    /**
     Fetch launches information.
     
     - parameter completion: A block that's called after launches infomation is obtained.
     
     - SeeAlso: `LaunchesDataTaskResult`
     */
    func fetchLaunches(completion: @escaping LaunchesDataTaskResult)
    
    /**
     Fetch a  specified launch information.
     
     - parameter number: flight number of the launch.
     - parameter completion: A block that's called after launch infomation is obtained.
     
     - SeeAlso: `LaunchDataTaskResult`
     */
    func fetchLaunch(withFlightNumber number: Int, completion: @escaping LaunchDataTaskResult)
    
    /**
     Fetch a specified rocket information.
     
     - parameter id: id of the rocket.
     - parameter completion: A block that's called after rocket infomation is obtained.
     
     - SeeAlso: `RocketDataTaskResult`
     */
    func fetchRocket(withRocketId id: String, completion: @escaping RocketDataTaskResult)
}
