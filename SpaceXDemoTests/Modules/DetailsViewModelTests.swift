//
//  DetailsViewModelTests.swift
//  SpaceXDemoTests
//
//  Created by Tim Li on 17/11/21.
//

import XCTest
@testable import SpaceXDemo
import RxSwift

class DetailsViewModelTests: XCTestCase {
    var sut: DetailsViewModel!
    var mockAPIService: MockAPIService!
    var mockViewController: MockDetailsViewController!
    var flightNumber: Int!
    var launch: Launch!
    var rocket: Rocket!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        flightNumber = 65
        launch = try givenLaunchFromJSON()
        rocket = try givenRocketFromJSON()
        
        mockAPIService = MockAPIService()
        mockAPIService.mockLaunch = launch
        mockAPIService.mockRocket = rocket
        sut = DetailsViewModel(apiService: mockAPIService, flightNumber: flightNumber)
        givenMockViewController()
    }
    
    override func tearDownWithError() throws {
        mockAPIService = nil
        mockViewController = nil
        flightNumber = nil
        launch = nil
        rocket = nil
        sut = nil
        try super.tearDownWithError()
    }
    
    func testDetailsViewModelsAfterInit() {
        XCTAssertEqual(sut.flightNumber, flightNumber)
        XCTAssertEqual(sut.launch.value, launch)
        XCTAssertEqual(sut.rocket.value, rocket)
        XCTAssertNotNil(sut.launchText.value)
        XCTAssertNotNil(sut.rocketText.value)
    }
    
    func testNotifyErrorWhenInit() {
        XCTAssertNil(sut.notifyError.value)
    }
    
    func testLaunchCallbackAfterFetched() {
        let exp = expectation(for: NSPredicate(block: { (mockViewController, _) -> Bool in
            return (mockViewController as! MockDetailsViewController).launchCallback
        }), evaluatedWith: mockViewController, handler: nil)

        whenGivenLaunch()

        wait(for: [exp], timeout: 2.0)
    }

    func testRocketCallbackAfterFetched() {
        let exp = expectation(for: NSPredicate(block: { (mockViewController, _) -> Bool in
            return (mockViewController as! MockDetailsViewController).rocketCallback
        }), evaluatedWith: mockViewController, handler: nil)

        whenGivenRocket()

        wait(for: [exp], timeout: 2.0)
    }
    
    func testNotifyErrorCallback_afterFetched() {
        let exp = expectation(for: NSPredicate(block: { (mockViewController, _) -> Bool in
            return (mockViewController as! MockDetailsViewController).notifyErrorCallback
        }), evaluatedWith: mockViewController, handler: nil)

        sut.notifyError.accept(.requestFailed)

        wait(for: [exp], timeout: 2.0)
    }
    
    func testLaunchTextCallbackWhenUpdated() {
        let title = "Test launch text"
        let exp = expectation(for: NSPredicate(block: { (mockViewController, _) -> Bool in
            return (mockViewController as! MockDetailsViewController).launchTextCallback == title
        }), evaluatedWith: mockViewController, handler: nil)
        
        sut.launchText.accept(title)
        
        wait(for: [exp], timeout: 2.0)
    }
    
    func testRocketTextCallbackWhenUpdated() {
        let title = "Test rocket text"
        let exp = expectation(for: NSPredicate(block: { (mockViewController, _) -> Bool in
            return (mockViewController as! MockDetailsViewController).rocketTextCallback == title
        }), evaluatedWith: mockViewController, handler: nil)
        
        sut.rocketText.accept(title)
        
        wait(for: [exp], timeout: 2.0)
    }

    func testFetchLaunchByFlightNumberSuccess() {
        mockAPIService.status = .success
        mockAPIService.mockLaunch = launch
        mockAPIService.mockErrorResponse = nil

        sut.fetchDetails()

        XCTAssertTrue(mockAPIService.isFetchLaunch)
        XCTAssertEqual(sut.launch.value, launch)
    }

    func testFetchLaunchByFlightNumberFailure() {
        let expectedError = NetworkError.requestFailed
        mockAPIService.status = .failure
        mockAPIService.mockLaunch = nil
        mockAPIService.mockErrorResponse = expectedError

        sut.fetchDetails()

        XCTAssertTrue(mockAPIService.isFetchLaunch)
        XCTAssertNil(sut.launch.value)
        XCTAssertNil(sut.rocket.value)
        XCTAssertNotNil(sut.notifyError.value)
        XCTAssertEqual(sut.notifyError.value?.localizedDescription, expectedError.localizedDescription)
    }
    
    func testFetchRocketByRocketIdSuccess() {
        mockAPIService.status = .success
        mockAPIService.mockRocket = rocket
        mockAPIService.mockErrorResponse = nil

        sut.fetchRocket(withRocketId: launch.rocket.id)

        XCTAssertTrue(mockAPIService.isFetchRocket)
        XCTAssertEqual(sut.rocket.value, rocket)
    }

    func testFetchRocketByRocketIdFailure() {
        let expectedError = NetworkError.requestFailed
        mockAPIService.status = .failure
        mockAPIService.mockLaunch = nil
        mockAPIService.mockErrorResponse = expectedError

        sut.fetchRocket(withRocketId: launch.rocket.id)

        XCTAssertTrue(mockAPIService.isFetchRocket)
        XCTAssertNil(sut.rocket.value)
        XCTAssertNotNil(sut.notifyError.value)
        XCTAssertEqual(sut.notifyError.value?.localizedDescription, expectedError.localizedDescription)
    }

    func testGenerateDetailsContent() throws {
        let (launchText, rocketText) = sut.generateDetailsContent(with: launch, and: rocket)

        XCTAssertNotNil(launchText)
        XCTAssertNotNil(rocketText)
    }
}

// MARK: data
extension DetailsViewModelTests {
    private func givenMockViewController() {
        mockViewController = MockDetailsViewController()
        mockViewController.viewModel = sut
        mockViewController.loadViewIfNeeded()
    }
    
    private func whenGivenLaunch(count: Int = 1) {
        guard count > 0 else {
            sut.launch.accept(nil)
            return
        }
        sut.launch.accept(givenLaunches(count: count).first)
    }
    
    private func whenGivenRocket() {
        sut.rocket.accept(givenRocket())
    }
    
    private func givenLaunchFromJSON() throws -> Launch {
        let decoder = JSONDecoder()
        let data = try Data.fromJSON(fileName: "\(Launch.self)")
        let launch = try decoder.decode(Launch.self, from: data)
        return launch
    }
    
    private func givenRocketFromJSON() throws -> Rocket {
        let decoder = JSONDecoder()
        let data = try Data.fromJSON(fileName: "\(Rocket.self)")
        let rocket = try decoder.decode(Rocket.self, from: data)
        return rocket
    }
}

class MockDetailsViewController: UIViewController {
    var viewModel: DetailsViewModelProtocol = DetailsViewModel(flightNumber: 65)
    var bag = DisposeBag()
    var launchCallback = false
    var rocketCallback = false
    var notifyErrorCallback = false
    var launchTextCallback = ""
    var rocketTextCallback = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupReactive()
    }
    
    func setupReactive() {
        viewModel.launch
            .asDriver()
            .drive(onNext: { [weak self] value in
                guard let self = self else {
                    return
                }
                
                self.launchCallback = true
            })
            .disposed(by: bag)
        
        viewModel.rocket
            .asDriver()
            .drive(onNext: { [weak self] value in
                guard let self = self else {
                    return
                }
                
                self.rocketCallback = true
            })
            .disposed(by: bag)
        
        viewModel.launchText
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let self = self else {
                    return
                }
                self.launchTextCallback = $0
            })
            .disposed(by: bag)
        
        viewModel.rocketText
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let self = self else {
                    return
                }
                self.rocketTextCallback = $0
            })
            .disposed(by: bag)
        
        viewModel.notifyError
            .asDriver()
            .drive(onNext: { [weak self] value in
                guard let self = self else {
                    return
                }
                
                self.notifyErrorCallback = true
            })
            .disposed(by: bag)
    }
}

