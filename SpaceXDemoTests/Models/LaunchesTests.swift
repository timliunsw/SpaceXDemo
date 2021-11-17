//
//  LaunchesTests.swift
//  SpaceXDemoTests
//
//  Created by Tim Li on 16/11/21.
//

import XCTest
@testable import SpaceXDemo

class LaunchesTests: XCTestCase {
    var sut: [Launch]!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        try! givenSUTFromJSON()
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
    
    func testDecodableSetsDocs() {
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.count, 4)
    }
    
    private func givenSUTFromJSON() throws {
        let decoder = JSONDecoder()
        let data = try Data.fromJSON(fileName: "Launches")
        let launches = try decoder.decode([Launch].self, from: data)
        sut = launches
    }
}
