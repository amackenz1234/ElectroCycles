//
//  ElectroCyclesUITests.swift
//  Electro CyclesUITests
//
//  Created by Assistant on 2026-02-04.
//

import XCTest

final class ElectroCyclesUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testAppLaunches() throws {
        let app = XCUIApplication()
        app.launch()
    }
}
