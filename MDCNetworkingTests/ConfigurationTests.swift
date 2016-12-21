//
//  ConfigurationTests.swift
//  MDCNetworking
//
//  Created by Despotovic, Mladen on 19/12/2016.
//  Copyright © 2016 Despotovic, Mladen. All rights reserved.
//

import XCTest
@testable import MDCNetworking

class ConfigurationTests: XCTestCase {
    
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
        let session1 = Configuration(host: "https://somehost")
        XCTAssertNotNil(session1)
        XCTAssertEqual(session1?.host.description, "https://somehost")
        
        // Additional headers
        let session2 = Configuration(host: "https://somehost",
                                            additionalHeaders: ["Accept-Encoding":"gzip", "Content-Type":"application/json"])
        XCTAssertNotNil(session2)
        XCTAssertEqual(session2?.additionalHeaders.count, 2)
        
        // Timeout
        let session3 = Configuration(host: "https://somehost",
                                            additionalHeaders: ["Accept-Encoding":"gzip", "Content-Type":"application/json"], timeout: 20)
        XCTAssertNotNil(session3)
        XCTAssertEqual(session3?.timeout, 20)
        
        // Session configuration
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        let session4 = Configuration(host: "https://somehost",
                                            additionalHeaders: ["Accept-Encoding":"gzip", "Content-Type":"application/json"],
                                            timeout: 20,
                                            sessionConfiguration: configuration)
        XCTAssertNotNil(session4)
        XCTAssertEqual(session4?.sessionConfiguration.timeoutIntervalForRequest, 20)
    }
    
    func testURLRequest() {
        
        // basic request
        var session = Configuration(host: "https://somehost")
        var request = session!.request(path: "https://somehost", parameters: nil)
        XCTAssertNotNil(request)
        XCTAssertEqual(request?.description, "https://somehost")
        
        // Single parameter
        session = Configuration(host: "https://somehost")
        request = session!.request(path: "https://somehost", parameters: ["parameter": "value"])
        XCTAssertNotNil(request)
        XCTAssertEqual(request?.description, "https://somehost?parameter=value")
        
        // Two parameters
        session = Configuration(host: "https://somehost")
        request = session!.request(path: "https://somehost", parameters: ["parameter": "value", "parameter1": "value1"])
        XCTAssertNotNil(request)
        XCTAssertEqual(request?.description, "https://somehost?parameter=value&parameter1=value1")
    }
}
