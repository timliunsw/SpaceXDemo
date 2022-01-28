//
//  APIService.swift
//  SpaceXDemo
//
//  Created by Tim Li on 15/9/21.
//

import Foundation

/**
 A  manager used for handling API service.
 */
struct APIService {
    /// Represents a shared manager used for API service.
    /// Use this instance for handling API calls.
    static let shared = APIService()
    
    /// The shared session.
    /// Provides an API for downloading data from and uploading data to endpoints indicated by URLs.
    private var session: URLSession
    
    /// The base URL.
    let baseUrlString: String
    
    /**
     `APIService` initialization.
     
     - parameter session: A URL session for  coordinating a group of related, network data transfer tasks.
     It is `the shared singleton session object` by default.
     - parameter baseUrl: The base URL for API request. It is `Constants.baseURL` by default.
     */
    init(session: URLSession = .shared, baseUrl: String = Constants.baseURL) {
        self.session = session
        self.baseUrlString = baseUrl
    }
    
    /**
     Perform retrieving data of a URL request.
     
     - parameter request: The request sent or to be sent to the server.
     - parameter completion: A block that's called after requested data is retireved.
     - Returns: A `URLSessionTask` instance.
     */
    @discardableResult
    private func perform(_ request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionTask {
        let task = session.dataTask(with: request) { data, response, error in
            guard
                error == nil,
                let responseData = data,
                let httpResponse = response as? HTTPURLResponse,
                200 ..< 300 ~= httpResponse.statusCode
            else {
                completion(.failure(error ?? NetworkError.invalidResponse(data, response)))
                return
            }
            
            completion(.success(responseData))
        }
        
        task.resume()
        return task
    }
    
    /**
     Wrapper for `func perform(_ request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionTask`.
     If decoding is succefully, the completion block will return a value of the specified type.
     
     - parameter request: The request sent or to be sent to the server.
     - parameter completion: A block that's called after requested data is retireved.
     Data is decoded with the specified type from a JSON object.
     - Returns: A `URLSessionTask` instance.
     - SeeAlso: `perform(_ request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionTask`
     */
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
}

// MARK: APIServiceProtocol
extension APIService: APIServiceProtocol {
    func fetchLaunches(completion: @escaping LaunchesDataTaskResult) {
        guard
            let baseURL = URL(string: baseUrlString),
            let urlComponents = NSURLComponents(url: baseURL.appendingPathComponent(Constants.SpaceXEndpoints.launches), resolvingAgainstBaseURL: true),
            let url = urlComponents.url
        else {
            completion(.failure(.badURL))
            return
        }
        
        let request = URLRequest(url: url)
        performJSON(request, of: [Launch].self) { result in
            switch result {
                case .success(let data):
                    completion(.success(data))
                case .failure(_):
                    completion(.failure(.requestFailed))
            }
        }
    }
    
    func fetchLaunch(withFlightNumber number: Int, completion: @escaping LaunchDataTaskResult) {
        guard
            let baseURL = URL(string: baseUrlString),
            let urlComponents = NSURLComponents(url: baseURL.appendingPathComponent("\(Constants.SpaceXEndpoints.launches)\(number)"), resolvingAgainstBaseURL: true),
            let url = urlComponents.url
        else {
            completion(.failure(.badURL))
            return
        }
        
        let request = URLRequest(url: url)
        performJSON(request, of: Launch.self) { result in
            switch result {
                case .success(let data):
                    completion(.success(data))
                case .failure(_):
                    completion(.failure(.requestFailed))
            }
        }
    }

    func fetchRocket(withRocketId id: String, completion: @escaping RocketDataTaskResult) {
        guard
            let baseURL = URL(string: baseUrlString),
            let urlComponents = NSURLComponents(url: baseURL.appendingPathComponent("\(Constants.SpaceXEndpoints.rockets)\(id)"), resolvingAgainstBaseURL: true),
            let url = urlComponents.url
        else {
            completion(.failure(.badURL))
            return
        }
        
        let request = URLRequest(url: url)
        performJSON(request, of: Rocket.self) { result in
            switch result {
                case .success(let data):
                    completion(.success(data))
                case .failure(_):
                    completion(.failure(.requestFailed))
            }
        }
    }
}

