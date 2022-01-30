//
//  APIRouter.swift
//  SpaceXDemo
//
//  Created by Tim Li on 30/1/22.
//

import Foundation

enum HTTPMethod: String {
    case POST
    case GET
    case PUT
    case DELETE
}

enum APIRouter {
    
    typealias Headers = [String: String?]
    case fetchLaunches
    case fetchLaunch(fightNumber: Int)
    case fetchRocket(id: String)
    
    var scheme: String {
        switch self {
        default:
            return "https"
        }
    }
    
    var host: String {
        switch self {
        default:
            return "api.spacexdata.com"
        }
    }
    
    var version: String {
        switch self {
        default:
            return "v3"
        }
    }
    
    var path: String {
        switch self {
        case .fetchLaunches:
            return "/\(version)/launches"
        case .fetchLaunch(let number):
            return "/\(version)/launches/\(number)"
        case .fetchRocket(let id):
            return "/\(version)/rockets/\(id)"
        }
    }
    
    var headers: Headers? {
        switch self {
        default:
            return ["Content-Type": "application/json; charset=utf-8"]
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        default:
            return nil
        }
    }
    
    var httpBody: Data? {
        switch self {
        default:
            return nil
        }
    }
    
    var method: HTTPMethod {
        switch self {
        default:
            return .GET
        }
    }
}
