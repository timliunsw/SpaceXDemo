//
//  LaunchTests.swift
//  SpaceXDemoTests
//
//  Created by Tim Li on 16/11/21.
//

import XCTest
@testable import SpaceXDemo

class LaunchTests: XCTestCase {
    var sut: Launch!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        try givenSUTFromJSON()
    }
    
    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Type Tests
    func testConformsToDecodable() {
        XCTAssertTrue((sut as Any) is Decodable)
    }
    
    func testConformsToEquatable() {
        XCTAssertEqual(sut, sut)
    }
    
    func testDecodableSetsFlightNumber() {
        XCTAssertEqual(sut.flightNumber, 65)
    }
    
    func testDecodableSetsMissionName() {
        XCTAssertEqual(sut.missionName, "Telstar 19V")
    }
    
    func testDecodableSetsLaunchYear() {
        XCTAssertEqual(sut.launchYear, "2018")
    }
    
    func testDecodableSetsLaunchDate() {
        XCTAssertEqual(sut.launchDate, 1532238600)
    }
    
    func testDecodableSetsLaunchSuccess() {
        XCTAssertEqual(sut.launchSuccess, true)
    }
    
    func testDecodableSetsDetails() {
        XCTAssertEqual(sut.details, "SSL-manufactured communications satellite intended to be placed at 63° West over the Americas. At 7,075 kg, it became the heaviest commercial communications satellite ever launched.")
    }
    
    func testDecodableSetsLink() {
        let link = Link(wikipedia: "https://en.wikipedia.org/wiki/Telstar_19V")
        XCTAssertEqual(sut.links, link)
    }
    
    func testDecodableSetsRocket() {
        let rocket = Rocket(id: "falcon9",
                            name: "Falcon 9",
                            type: "FT",
                            description: nil,
                            country: nil,
                            company: nil)
        XCTAssertEqual(sut.rocket, rocket)
    }
    
    private func givenSUTFromJSON() throws {
        let decoder = JSONDecoder()
        let data = try Data.fromJSON(fileName: "\(Launch.self)")
        let launch = try decoder.decode(Launch.self, from: data)
        sut = launch
    }
}
