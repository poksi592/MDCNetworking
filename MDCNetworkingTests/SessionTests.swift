//
//  SessionTests.swift
//  MDCNetworking
//
//  Created by Despotovic, Mladen on 19/12/2016.
//  Copyright © 2016 Despotovic, Mladen. All rights reserved.
//

import XCTest
@testable import MDCNetworking

class SessionTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInitialising() {
    
        // Test with default GET method
        let session1 = JSONSession(requestURLPath: "https://somehost") { (result, response, error, cancelled) in }
        XCTAssertNotNil(session1)
        guard case .GET = session1.HTTPMethod else {
            XCTAssert(false, "error")
            return
        }
    }
    
    func testStartSession() {
        
        // Prepare without Configuration object set
        let expectationForTest = expectation(description: "test")
        // Execute and test
        let session1 = JSONSession(requestURLPath: "https://somehost") { (result, response, error, cancelled) in
            
            XCTAssertNotNil(error)
            let error = error! as NetworkError
            guard case .NoConfiguration = error else {
                XCTAssertTrue(false, "error")
                return
            }
            expectationForTest.fulfill()
        }
        XCTAssertNotNil(session1)
        session1.start()
        waitForExpectations(timeout: 5, handler: nil)
    }

    
    
    
}

/*
 // Test with GET method
 let session2 = Configuration(host: "https://somehost")
 let client2 = Client(configuration: session2!, method: .GET)
 XCTAssertNotNil(client2)
 guard case .GET = client2!.method else {
 XCTAssert(false, "error")
 return
 }
 
 // Test with POST method
 let session3 = Configuration(host: "https://somehost")
 let client3 = Client(configuration: session3!, method: .POST)
 XCTAssertNotNil(client3)
 guard case .POST = client3!.method else {
 XCTAssert(false, "error")
 return
 }
 
 // Test with parameters
 let session4 = Configuration(host: "https://somehost")
 let client4 = Client(configuration: session4!,
 method: .POST,
 parameters: ["par1":"value1","par2":"value2"])
 XCTAssertNotNil(client4)
 guard case .POST = client4!.method,
 let _ = client4?.parameters else {
 XCTAssert(false, "error")
 return
 }
 */

