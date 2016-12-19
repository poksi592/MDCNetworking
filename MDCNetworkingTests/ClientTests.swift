//
//  ClientTests.swift
//  MDCNetworking
//
//  Created by Despotovic, Mladen on 19/12/2016.
//  Copyright © 2016 Despotovic, Mladen. All rights reserved.
//

import XCTest
@testable import MDCNetworking

class ClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testClientInitialization() {
        
        // Test with configuration
        let session1 = Configuration(host: "https://somehost")
        let client1 = Client(configuration: session1!)
        XCTAssertNotNil(client1)
        XCTAssertNotNil(client1?.configuration)
        
    }

    
}
