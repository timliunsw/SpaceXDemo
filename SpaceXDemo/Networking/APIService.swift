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
    
    /**
     `APIService` initialization.
     
     - parameter session: A URL session for  coordinating a group of related, network data transfer tasks.
     It is `the shared singleton session object` by default.
     */
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    /**
     Create URLComponents based on the API router with specified route.
     
     - parameter router: An API router with specified route.
     
     - Returns: A `URLComponents` instance.
     */
    private func createComponents(router: APIRouter) -> URLComponents {
        var components = URLComponents()
        components.scheme = router.scheme
        components.host = router.host
        components.path = router.path
        components.queryItems = router.queryItems
        return components
    }
    
    /**
     Create URLRequest based on the API router with specified route.
     
     - parameter router: An API router with specified route.
     
     - Returns: A `URLRequest` instance. The return may be `NULL`.
     */
    private func createURLRequest(router: APIRouter) -> URLRequest? {
        let components = createComponents(router: router)
        guard let url = components.url else {
            return nil
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = router.method.rawValue
        if let headers = router.headers {
            for item in headers {
                urlRequest.setValue(item.value, forHTTPHeaderField: item.key)
            }
        }
        
        if let httpBody = router.httpBody {
            urlRequest.httpBody = httpBody
        }
        return urlRequest
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
        let router: APIRouter = .fetchLaunches
        guard let request = createURLRequest(router: router) else {
            completion(.failure(.badURL))
            return
        }
        
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
        let router: APIRouter = .fetchLaunch(fightNumber: number)
        guard let request = createURLRequest(router: router) else {
            completion(.failure(.badURL))
            return
        }
        
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
        let router: APIRouter = .fetchRocket(id: id)
        guard let request = createURLRequest(router: router) else {
            completion(.failure(.badURL))
            return
        }
        
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

