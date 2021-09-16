//
//  Link.swift
//  SpaceXDemo
//
//  Created by Tim Li on 15/9/21.
//

import Foundation

class Link: BaseModel {
    var wikipedia: String
    
    enum CodingKeys: String, CodingKey {
        case wikipedia
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        wikipedia = try container.decodeIfPresent(String.self, forKey: .wikipedia) ?? ""
    }
    
    func encode(to encoder: Encoder) throws { }
}
