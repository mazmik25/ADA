//
//  ADATests.swift
//  ADATests
//
//  Created by Azmi Muhammad on 18/09/19.
//  Copyright © 2019 Azmi Muhammad. All rights reserved.
//

import XCTest
@testable import ADA

class ADATests: XCTestCase {

    private var database: Database!
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        database = BaseDatabase(key: .Profile)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        database = nil
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testSavingUsers() {
        let user: User = User(email: "test@email.com", name: "azmi", dateOfBirth: "September 19, 1996", uuid: "", lat: 100.0, long: 100.0)
        database.save(model: user) { (err) in
            XCTAssertNotNil(err, "Err doest'n nil when there's an error in saving data")
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
