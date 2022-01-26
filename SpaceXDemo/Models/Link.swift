//
//  Link.swift
//  SpaceXDemo
//
//  Created by Tim Li on 15/9/21.
//

import Foundation

struct Link {
    let wikipedia: String
    
    private enum CodingKeys: String, CodingKey {
        case wikipedia
    }
}

extension Link: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        wikipedia = try container.decodeIfPresent(String.self, forKey: .wikipedia) ?? ""
    }
    
    func encode(to encoder: Encoder) throws { }
}

extension Link: Equatable {
    static func == (lhs: Link, rhs: Link) -> Bool {
        return lhs.wikipedia == rhs.wikipedia
    }
}
