//
//  LaunchListViewModelTests.swift
//  SpaceXDemoTests
//
//  Created by Tim Li on 17/11/21.
//

import XCTest
@testable import SpaceXDemo
import RxSwift

class LaunchListViewModelTests: XCTestCase {
    var sut: LaunchListViewModel!
    var mockAPIService: MockAPIService!
    var mockViewController: MockLaunchListViewController!
    var launches: [Launch]!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        launches = try givenLaunchesFromJSON()
        mockAPIService = MockAPIService()
        mockAPIService.mockLaunches = []
        sut = LaunchListViewModel(apiService: mockAPIService)
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
    }
    
    func testNotifyErrorwhenInit() {
        XCTAssertNil(sut.notifyError.value)
    }
    
    func testLaunchesCallbackAfterFetched() {
        let exp = expectation(for: NSPredicate(block: { (mockViewController, _) -> Bool in
            return (mockViewController as! MockLaunchListViewController).launchesCallback
        }), evaluatedWith: mockViewController, handler: nil)
        
        whenGivenLaunches()
        
        wait(for: [exp], timeout: 2.0)
    }
    
    func testNotifyErrorCallbackAfterFetched() {
        let exp = expectation(for: NSPredicate(block: { (mockViewController, _) -> Bool in
            return (mockViewController as! MockLaunchListViewController).notifyErrorCallback
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
        sut.filterLaunchesBy(status: true)
        
        XCTAssertNotNil(sut.launchesObservable.value)
        XCTAssertEqual(sut.launchesObservable.value.count, successfulLaunches.count)
    }
    
    func testLaunchesFilteredByFailure() {
        let failedLaunches = launches.filter { !$0.launchSuccess }
        
        mockAPIService.status = .success
        mockAPIService.mockLaunches = launches
        mockAPIService.mockErrorResponse = nil
        
        sut.fetchLaunches()
        sut.filterLaunchesBy(status: false)
        
        XCTAssertNotNil(sut.launchesObservable.value)
        XCTAssertEqual(sut.launchesObservable.value.count, failedLaunches.count)
    }
}

// MARK: data
extension LaunchListViewModelTests {
    private func givenMockViewController() {
        mockViewController = MockLaunchListViewController()
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

class MockLaunchListViewController: UIViewController {
    var viewModel: LaunchListViewModelProtocol = LaunchListViewModel()
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
