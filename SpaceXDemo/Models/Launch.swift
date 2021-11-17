//
//  Launch.swift
//  SpaceXDemo
//
//  Created by Tim Li on 16/9/21.
//

import Foundation

class Launch: BaseModel {
    var flightNumber: Int
    var missionName: String
    var launchYear: String
    var launchDate: Int
    var launchSuccess: Bool
    var details: String
    var links: Link
    var rocket: Rocket
    
    enum CodingKeys: String, CodingKey {
        case flightNumber = "flight_number"
        case missionName = "mission_name"
        case launchYear = "launch_year"
        case launchDate = "launch_date_unix"
        case launchSuccess = "launch_success"
        case links, details, rocket
    }
    
    init(flightNumber: Int, missionName: String, launchYear: String, launchDate: Int, launchSuccess: Bool, links: Link, details: String, rocket: Rocket) {
        self.flightNumber = flightNumber
        self.missionName = missionName
        self.launchYear = launchYear
        self.launchDate = launchDate
        self.launchSuccess = launchSuccess
        self.links = links
        self.details = details
        self.rocket = rocket
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        flightNumber = try container.decodeIfPresent(Int.self, forKey: .flightNumber) ?? 0
        missionName = try container.decodeIfPresent(String.self, forKey: .missionName) ?? ""
        launchYear = try container.decodeIfPresent(String.self, forKey: .launchYear) ?? ""
        launchDate = try container.decodeIfPresent(Int.self, forKey: .launchDate) ?? 0
        launchSuccess = try container.decodeIfPresent(Bool.self, forKey: .launchSuccess) ?? false
        details = try container.decodeIfPresent(String.self, forKey: .details) ?? ""
        links = try container.decodeIfPresent(Link.self, forKey: .links)!
        rocket = try container.decodeIfPresent(Rocket.self, forKey: .rocket)!
    }
    
    func encode(to encoder: Encoder) throws { }
    
    static func == (lhs: Launch, rhs: Launch) -> Bool {
        return lhs.flightNumber == rhs.flightNumber
    }
}

