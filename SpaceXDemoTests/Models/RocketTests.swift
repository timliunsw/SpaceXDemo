//
//  RocketTests.swift
//  SpaceXDemoTests
//
//  Created by Tim Li on 16/11/21.
//

import XCTest
@testable import SpaceXDemo

class RocketTests: XCTestCase {
    var sut: Rocket!
    
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
    
    func testDecodableSetsRocketId() {
        XCTAssertEqual(sut.id, "falcon9")
    }
    
    func testDecodableSetsRocketName() {
        XCTAssertEqual(sut.name, "Falcon 9")
    }
    
    func testDecodableSetsRocketType() {
        XCTAssertEqual(sut.type, "rocket")
    }
    
    func testDecodableSetsRocketDescription() {
        XCTAssertEqual(sut.description, "Falcon 9 is a two-stage rocket designed and manufactured by SpaceX for the reliable and safe transport of satellites and the Dragon spacecraft into orbit.")
    }
    
    func testDecodableSetsRocketCountry() {
        XCTAssertEqual(sut.country, "United States")
    }
    
    func testDecodableSetsRocketCompany() {
        XCTAssertEqual(sut.company, "SpaceX")
    }
    
    private func givenSUTFromJSON() throws {
        let decoder = JSONDecoder()
        let data = try Data.fromJSON(fileName: "\(Rocket.self)")
        let rocket = try decoder.decode(Rocket.self, from: data)
        sut = rocket
    }
}

