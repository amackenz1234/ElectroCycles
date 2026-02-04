//
//  ElectroCyclesTests.swift
//  Electro CyclesTests
//
//  Created by Assistant on 2026-02-04.
//

import XCTest
@testable import Electro_Cycles

final class ElectroCyclesTests: XCTestCase {

    func testCatalogHasBikes() {
        XCTAssertFalse(Catalog.bikes.isEmpty, "Catalog should contain bikes")
    }

    func testBikeHasValidPrice() {
        for bike in Catalog.bikes {
            XCTAssertGreaterThan(bike.price, 0, "\(bike.name) should have a positive price")
        }
    }

    func testBikeHasName() {
        for bike in Catalog.bikes {
            XCTAssertFalse(bike.name.isEmpty, "Each bike should have a name")
        }
    }
}
