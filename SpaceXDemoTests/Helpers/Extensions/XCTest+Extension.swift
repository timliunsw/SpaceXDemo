//
//  XCTest+Extension.swift
//  SpaceXDemoTests
//
//  Created by Tim Li on 16/11/21.
//

import Foundation
import XCTest
@testable import SpaceXDemo

extension XCTest {
    func givenLaunches(count: Int) -> [Launch] {
        return (1 ... count).map { i in
            return Launch(flightNumber: i,
                          missionName: "missionName_\(i)",
                          launchYear: "\(i)",
                          launchDate: i,
                          launchSuccess: true,
                          links: Link(wikipedia: "https://en.wikipedia.org/wiki/DemoSat"),
                          details: "details_\(i)",
                          rocket: Rocket(id: "rocket_\(i)",
                                         name: "rocketName_\(i)",
                                         type: "rocket",
                                         description: "description_rocket_\(i)",
                                         country: "country_rocket_\(i)",
                                         company: "company_rocket_\(i)"))
        }
    }
    
    func givenRocket() -> Rocket {
        return Rocket(id: "rocket_test",
                      name: "rocketName_test",
                      type: "rocket",
                      description: "description_rocket_test",
                      country: "country_rocket_test",
                      company: "company_rocket_test")
    }
}
