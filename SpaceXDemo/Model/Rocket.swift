//
//  Rocket.swift
//  SpaceXDemo
//
//  Created by Tim Li on 15/9/21.
//

import Foundation

class Rocket: BaseModel {
    var id: String
    var name: String
    var type: String
    var description: String?
    var country: String?
    var company: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "rocket_id"
        case name = "rocket_name"
        case type = "rocket_type"
        case description, country, company
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        type = try container.decodeIfPresent(String.self, forKey: .type) ?? ""
        description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        country = try container.decodeIfPresent(String.self, forKey: .country) ?? ""
        company = try container.decodeIfPresent(String.self, forKey: .company) ?? ""
    }
    
    func encode(to encoder: Encoder) throws { }
}
