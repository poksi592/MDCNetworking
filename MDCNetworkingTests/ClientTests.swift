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
        let session1 = SessionConfiguration(host: "https://somehost")
        let client1 = Client(configuration: session1!)
        XCTAssertNotNil(client1)
        XCTAssertNotNil(client1?.configuration)
        
        // Test with GET method
        let session2 = SessionConfiguration(host: "https://somehost")
        let client2 = Client(configuration: session2!, method: .GET)
        XCTAssertNotNil(client2)
        guard case .GET = client2!.method else {
            XCTAssert(false, "error")
            return
        }
        
        // Test with POST method
        let session3 = SessionConfiguration(host: "https://somehost")
        let client3 = Client(configuration: session3!, method: .POST)
        XCTAssertNotNil(client3)
        guard case .POST = client3!.method else {
            XCTAssert(false, "error")
            return
        }
        
        // Test with parameters
        let session4 = SessionConfiguration(host: "https://somehost")
        let client4 = Client(configuration: session4!,
                             method: .POST,
                             parameters: ["par1":"value1","par2":"value2"])
        XCTAssertNotNil(client4)
        guard case .POST = client4!.method,
                let _ = client4?.parameters else {
            XCTAssert(false, "error")
            return
        }
        
    }

    
}
