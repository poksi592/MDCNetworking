//
//  SessionConfigurationTests.swift
//  MDCNetworking
//
//  Created by Despotovic, Mladen on 19/12/2016.
//  Copyright © 2016 Despotovic, Mladen. All rights reserved.
//

import XCTest
@testable import MDCNetworking

class SessionConfigurationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInstantiation() {
        
        // Designated initializer
        let session1 = SessionConfiguration(host: "https://somehost")
        XCTAssertNotNil(session1)
        XCTAssertEqual(session1?.host.description, "https://somehost")
        
        // Additional headers
        let session2 = SessionConfiguration(host: "https://somehost",
                                            additionalHeaders: ["Accept-Encoding":"gzip", "Content-Type":"application/json"])
        XCTAssertNotNil(session2)
        XCTAssertEqual(session2?.additionalHeaders?.count, 2)
        
        // Timeout
        let session3 = SessionConfiguration(host: "https://somehost",
                                            additionalHeaders: ["Accept-Encoding":"gzip", "Content-Type":"application/json"], timeout: 20)
        XCTAssertNotNil(session3)
        XCTAssertEqual(session3?.timeout, 20)
    }
    

    
}
