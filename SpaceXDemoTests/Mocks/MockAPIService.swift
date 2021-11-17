//
//  MockAPIService.swift
//  SpaceXDemoTests
//
//  Created by Tim Li on 16/11/21.
//

@testable import SpaceXDemo
import Foundation

class MockAPIService: APIServiceProtocol {
    enum Status {
        case success
        case failure
    }
    var mockLaunches: [Launch]?
    var mockLaunch: Launch?
    var mockRocket: Rocket?
    var mockErrorResponse: NetworkError?
    var isFetchLaunches = false
    var isFetchLaunch = false
    var isFetchRocket = false
    var status: Status = .success
    
    func fetchLaunches(completion: @escaping LaunchesDataTaskResult) {
        isFetchLaunches = true
        
        switch status {
            case .success:
                completion(.success(mockLaunches!))
            case .failure:
                completion(.failure(.requestFailed))
        }
    }
    
    func fetchLaunch(withFlightNumber number: Int, completion: @escaping LaunchDataTaskResult) {
        isFetchLaunch = true
        
        switch status {
            case .success:
                completion(.success(mockLaunch!))
            case .failure:
                completion(.failure(.requestFailed))
        }
    }
    
    func fetchRocket(withRocketId id: String, completion: @escaping RocketDataTaskResult) {
        isFetchRocket = true
        
        switch status {
            case .success:
                completion(.success(mockRocket!))
            case .failure:
                completion(.failure(.requestFailed))
        }
    }
}
