//
//  APIService.swift
//  SpaceXDemo
//
//  Created by Tim Li on 15/9/21.
//

import Foundation

typealias LaunchesDataTaskResult = (_ success: Bool, _ data: [Launch]?, _ error: Error?)->()
typealias LaunchDataTaskResult = (_ success: Bool, _ data: Launch?, _ error: Error?)->()
typealias RocketDataTaskResult = (_ success: Bool, _ data: Rocket?, _ error: Error?)->()

enum APIServiceError: Error {
    case invalidResponse(Data?, URLResponse?)
}

class APIService {
    static let shared = APIService()
    private var session: URLSession
    
    private init() {
        session = .shared
    }
    
    @discardableResult
    private func perform(_ request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionTask {
        let task = session.dataTask(with: request) { data, response, error in
            guard
                error == nil,
                let responseData = data,
                let httpResponse = response as? HTTPURLResponse,
                200 ..< 300 ~= httpResponse.statusCode
            else {
                completion(.failure(error ?? APIServiceError.invalidResponse(data, response)))
                return
            }
            
            completion(.success(responseData))
        }
        
        task.resume()
        return task
    }
    
    @discardableResult
    private func performJSON<T: Decodable>(_ request: URLRequest, of type: T.Type, completion: @escaping (Result<T, Error>) -> Void) -> URLSessionTask {
        return perform(request) { result in
            switch result {
                case .failure(let error):
                    completion(.failure(error))
                    
                case .success(let data):
                    do {
                        let responseObject = try JSONDecoder().decode(T.self, from: data)
                        completion(.success(responseObject))
                    } catch let parseError {
                        completion(.failure(parseError))
                    }
            }
        }
    }
    
    func fetchLaunches(completion: @escaping LaunchesDataTaskResult) {
        guard
            let baseURL = URL(string: Constants.baseURL),
            let urlComponents = NSURLComponents(url: baseURL.appendingPathComponent(Constants.SpaceXEndpoints.launches), resolvingAgainstBaseURL: true),
            let url = urlComponents.url
        else {
            return
        }
        
        let request = URLRequest(url: url)
        performJSON(request, of: [Launch].self) { result in
            switch result {
                case .success(let data):
                    completion(true, data, nil)
                case .failure(let error):
                    completion(false, nil , error)
            }
        }
    }
    
    func fetchLaunch(withFlightNumber number: Int, completion: @escaping LaunchDataTaskResult) {
        guard
            let baseURL = URL(string: Constants.baseURL),
            let urlComponents = NSURLComponents(url: baseURL.appendingPathComponent("\(Constants.SpaceXEndpoints.launches)\(number)"), resolvingAgainstBaseURL: true),
            let url = urlComponents.url
        else {
            return
        }
        
        let request = URLRequest(url: url)
        performJSON(request, of: Launch.self) { result in
            switch result {
                case .success(let data):
                    completion(true, data, nil)
                case .failure(let error):
                    completion(false, nil , error)
            }
        }
    }

    func fetchRocket(withRocketId id: String, completion: @escaping RocketDataTaskResult) {
        guard
            let baseURL = URL(string: Constants.baseURL),
            let urlComponents = NSURLComponents(url: baseURL.appendingPathComponent("\(Constants.SpaceXEndpoints.rockets)\(id)"), resolvingAgainstBaseURL: true),
            let url = urlComponents.url
        else {
            return
        }
        
        let request = URLRequest(url: url)
        performJSON(request, of: Rocket.self) { result in
            switch result {
                case .success(let data):
                    completion(true, data, nil)
                case .failure(let error):
                    completion(false, nil , error)
            }
        }
    }
}

