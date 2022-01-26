//
//  SpaceXDemoUITests.swift
//  SpaceXDemoUITests
//
//  Created by Tim Li on 15/9/21.
//

import XCTest

class SpaceXDemoUITests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUp() {
        app.launch()
    }
}

// MARK: UI Components existence tests
extension SpaceXDemoUITests {
    func testUIComponentsExistenceInLandscapeMode() {
        XCUIDevice.shared.orientation = .landscapeLeft
        
        let tableView = app.tables["Launches Table View"]
        XCTAssertTrue(tableView.exists, "Launches Table View exists")
        
        let navigationBar = app.navigationBars["SpaceX Launches"]
        XCTAssertTrue(navigationBar.exists, "Launches Table View exists")
        
        let resetButton = navigationBar.buttons["Reset"]
        XCTAssertTrue(resetButton.exists, "Reset Button exists")
        
        let sortButton = navigationBar.buttons["Sort"]
        XCTAssertTrue(sortButton.exists, "Sort Button exists")
        
        let filterButton = navigationBar.buttons["Filter"]
        XCTAssertTrue(filterButton.exists, "Filter button exists")
    }
    
    func testUIComponentsExistenceInPortraitMode() {
        XCUIDevice.shared.orientation = .portrait
        
        let tableView = app.tables["Launches Table View"]
        XCTAssertTrue(tableView.exists, "Launches Table View exists")
        
        let navigationBar = app.navigationBars["SpaceX Launches"]
        XCTAssertTrue(navigationBar.exists, "Launches Table View exists")
        
        let resetButton = navigationBar.buttons["Reset"]
        XCTAssertTrue(resetButton.exists, "Reset Button exists")
        
        let sortButton = navigationBar.buttons["Sort"]
        XCTAssertTrue(sortButton.exists, "Sort Button exists")
        
        let filterButton = navigationBar.buttons["Filter"]
        XCTAssertTrue(filterButton.exists, "Filter button exists")
    }
}

// MARK: Buttons
extension SpaceXDemoUITests {
    func testCellDetailButtonInteraction() {
        let predicate = NSPredicate(format: "exists == 1")
        let cell = app.tables.cells["No.1"]
        expectation(for: predicate, evaluatedWith: cell, handler: nil)

        waitForExpectations(timeout: 30, handler: nil)
        
        let detailButton = cell.buttons["More Info"]
        XCTAssertTrue(detailButton.exists, "Detail button exists")
        
        detailButton.tap()
    }
    
    func testFilterButton() {
        let filterButton = app.navigationBars.buttons["Filter"]
        XCTAssertTrue(filterButton.exists, "Filter button exists")
        
        filterButton.tap()
        
        let filterSheet = app.sheets["Filter launches"]
        XCTAssertTrue(filterSheet.exists, "Filter alert exists")
                
        let successFilterButton = filterSheet.buttons["By launch success"]
        XCTAssertTrue(successFilterButton.exists, "Success filter option exists")
        successFilterButton.tap()
        
        filterButton.tap()
        
        let failedFilterButton = filterSheet.buttons["By launch failure"]
        XCTAssertTrue(failedFilterButton.exists, "Failure filter option exists")
        failedFilterButton.tap()
        
        filterButton.tap()
        
        let cancelButton = filterSheet.buttons["Cancel"]
        XCTAssertTrue(cancelButton.exists, "Cancel button exists")
        cancelButton.tap()
    }
    
    func testSortButton() {
        let sortButton = app.navigationBars.buttons["Sort"]
        XCTAssertTrue(sortButton.exists, "Sort button exists")
        
        sortButton.tap()
        
        let sortSheet = app.sheets["Sort launches"]
        XCTAssertTrue(sortSheet.exists, "Sort alert exists")
                
        let launchDateButton = sortSheet.buttons["By launch date"]
        XCTAssertTrue(launchDateButton.exists, "By launch date option exists")
        launchDateButton.tap()
        
        sortButton.tap()
        
        let missionNameButton = sortSheet.buttons["By mission name"]
        XCTAssertTrue(missionNameButton.exists, "By mission name option exists")
        missionNameButton.tap()
        
        sortButton.tap()
        
        let cancelButton = sortSheet.buttons["Cancel"]
        XCTAssertTrue(cancelButton.exists, "Cancel button exists")
        cancelButton.tap()
    }
    
    func testResetButton() {
        let resetButton = app.navigationBars.buttons["Reset"]
        XCTAssertTrue(resetButton.exists, "Reset button exists")
        
        resetButton.tap()
    }
}

// MARK: TableView Interaction
extension SpaceXDemoUITests {
    func testInteractionOfLaunchesTableView() {
        let tableView = app.tables["Launches Table View"]
        XCTAssertTrue(tableView.exists)

        let cells = tableView.cells

        if cells.count > 0 {
            let count: Int = (cells.count - 1)

            let promise = expectation(description: "Wait for table cells")
            
            // If the number of cells is more than 10, will test 10 times.
            let times = count > 10 ? 10 : count
            for i in stride(from: 0, to: times , by: 1) {
                // Grab the first cell and verify that it exists and tap it
                let tableCell = cells.element(boundBy: i)
                XCTAssertTrue(tableCell.exists, "The \(i) cell is in place on the table")
                // Does this actually take us to the next screen
                tableCell.tap()

                if i == (times - 1) {
                    promise.fulfill()
                }
                // Back
                app.navigationBars.buttons.element(boundBy: 0).tap()
            }
            waitForExpectations(timeout: 30, handler: nil)
            XCTAssertTrue(true, "Finished validating the table cells")

        } else {
            XCTAssert(false, "Was not able to find any table cells")
        }
    }
}
