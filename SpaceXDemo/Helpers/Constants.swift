//
//  Constants.swift
//  SpaceXDemo
//
//  Created by Tim Li on 15/9/21.
//

import UIKit

enum Constants {
    static let baseURL = "https://api.spacexdata.com/v3"
    
    enum SpaceXEndpoints {
        static let launches = "launches/"
        static let rockets = "rockets/"
    }
    
    static let cellId = "CellIdentifier"
    static let accessibilityIdentifier = "Launches Table View"
}
