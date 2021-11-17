//
//  NetworkError.swift
//  SpaceXDemo
//
//  Created by Tim Li on 15/11/21.
//

import Foundation

enum NetworkError: Error {
    case invalidResponse(Data?, URLResponse?)
    case badURL
    case requestFailed
}

extension NetworkError {
    var localizedDescription: String {
        switch self {
        case .invalidResponse:
            return "System.Network.Error.Invalid".localized
        case .badURL:
            return "System.Network.Error.BadUrl".localized
        case .requestFailed:
            return "System.Network.Error.RequestFailed".localized
        }
    }
}
