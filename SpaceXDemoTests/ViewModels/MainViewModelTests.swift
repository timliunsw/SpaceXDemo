//
//  MainViewModelTests.swift
//  SpaceXDemoTests
//
//  Created by Tim Li on 17/11/21.
//

import XCTest
@testable import SpaceXDemo
import RxSwift

class MainViewModelTests: XCTestCase {
    var sut: MainViewModel!
    var mockAPIService: MockAPIService!
    var mockViewController: MockMainViewController!
    var launches: [Launch]!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        launches = try givenLaunchesFromJSON()
        mockAPIService = MockAPIService()
        mockAPIService.mockLaunches = []
        sut = MainViewModel(apiService: mockAPIService)
        givenMockViewController()
    }
    
    override func tearDownWithError() throws {
        mockAPIService = nil
        mockViewController = nil
        launches = nil
        sut = nil
        try super.tearDownWithError()
    }
    
    func testLaunchViewModelsAfterInit() {
        XCTAssertTrue(sut.launches.value.isEmpty)
        XCTAssertTrue(sut.launchesObservable.value.isEmpty)
        XCTAssertTrue(sut.filteredLaunches.value.isEmpty)
    }
    
    func testNotifyErrorwhenInit() {
        XCTAssertNil(sut.notifyError.value)
    }
    
    func testLaunchesCallbackAfterFetched() {
        let exp = expectation(for: NSPredicate(block: { (mockViewController, _) -> Bool in
            return (mockViewController as! MockMainViewController).launchesCallback
        }), evaluatedWith: mockViewController, handler: nil)
        
        whenGivenLaunches()
        
        wait(for: [exp], timeout: 2.0)
    }
    
    func testNotifyErrorCallbackAfterFetched() {
        let exp = expectation(for: NSPredicate(block: { (mockViewController, _) -> Bool in
            return (mockViewController as! MockMainViewController).notifyErrorCallback
        }), evaluatedWith: mockViewController, handler: nil)
        
        sut.notifyError.accept(.requestFailed)
        
        wait(for: [exp], timeout: 2.0)
    }
    
    func testFetchLaunchesSuccess() {
        mockAPIService.status = .success
        mockAPIService.mockLaunches = launches
        mockAPIService.mockErrorResponse = nil
        
        sut.fetchLaunches()
        
        XCTAssertTrue(mockAPIService.isFetchLaunches)
        XCTAssertEqual(sut.launches.value, launches)
    }
    
    func testFetchLaunchesFailure() {
        let expectedError = NetworkError.requestFailed
        mockAPIService.status = .failure
        mockAPIService.mockLaunches = nil
        mockAPIService.mockErrorResponse = expectedError
        
        sut.fetchLaunches()
        
        XCTAssertTrue(mockAPIService.isFetchLaunches)
        XCTAssertTrue(sut.launches.value.isEmpty)
        XCTAssertNotNil(sut.notifyError.value)
        XCTAssertEqual(sut.notifyError.value?.localizedDescription, expectedError.localizedDescription)
    }
    
    func testLaunchesSortedByMissionName() {
        mockAPIService.status = .success
        mockAPIService.mockLaunches = launches
        mockAPIService.mockErrorResponse = nil
        
        sut.fetchLaunches()
        
        XCTAssertNotNil(sut.launches.value)
        XCTAssertGreaterThan(sut.launchesObservable.value.count, 2)
        
        sut.launchesSortedByMissionName()
        
        XCTAssertLessThanOrEqual(sut.launchesObservable.value[0].header, sut.launchesObservable.value[1].header)
    }
    
    func testLaunchesSortedByDate() {
        mockAPIService.status = .success
        mockAPIService.mockLaunches = launches
        mockAPIService.mockErrorResponse = nil
        
        sut.fetchLaunches()
        
        XCTAssertNotNil(sut.launches.value)
        XCTAssertGreaterThan(sut.launchesObservable.value.count, 2)
        
        sut.launchesSortedByDate()
        
        XCTAssertLessThanOrEqual(sut.launchesObservable.value[0].header, sut.launchesObservable.value[1].header)
    }
    
    func testLaunchesFilteredBySuccess() {
        let successfulLaunches = launches.filter { $0.launchSuccess }
        
        mockAPIService.status = .success
        mockAPIService.mockLaunches = launches
        mockAPIService.mockErrorResponse = nil
        
        sut.fetchLaunches()
        sut.launchesFilteredBySuccess()
        
        XCTAssertNotNil(sut.launchesObservable.value)
        XCTAssertEqual(sut.launchesObservable.value.count, successfulLaunches.count)
    }
}

// MARK: data
extension MainViewModelTests {
    private func givenMockViewController() {
        mockViewController = MockMainViewController()
        mockViewController.viewModel = sut
        mockViewController.loadViewIfNeeded()
    }
    
    private func whenGivenLaunches(count: Int = 5) {
        guard count > 0 else {
            sut.launches.accept([])
            return
        }
        sut.launches.accept(givenLaunches(count: count))
    }
    
    private func givenLaunchesFromJSON() throws -> [Launch] {
        let decoder = JSONDecoder()
        let data = try Data.fromJSON(fileName: "Launches")
        let launches = try decoder.decode([Launch].self, from: data)
        return launches
    }
}

class MockMainViewController: UIViewController {
    var viewModel: MainViewModelProtocol = MainViewModel()
    var bag = DisposeBag()
    var launchesCallback = false
    var notifyErrorCallback = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupReactive()
    }
    
    func setupReactive() {
        viewModel.launches
            .asDriver()
            .drive(onNext: { [weak self] value in
                guard let self = self else {
                    return
                }
                
                self.launchesCallback = true
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
