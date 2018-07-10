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
        let session1 = try? Configuration(scheme: "https", host: "somehost")
        XCTAssertEqual(session1?.baseUrl.host?.description, "somehost")
        
        // Additional headers
        let session2 = try? Configuration(scheme: "https", host: "somehost",
                                            additionalHeaders: ["Accept-Encoding":"gzip", "Content-Type":"application/json"])
        XCTAssertEqual(session2?.additionalHeaders.count, 2)
        
        // Timeout
        let session3 = try? Configuration(scheme: "https", host: "somehost",
                                            additionalHeaders: ["Accept-Encoding":"gzip", "Content-Type":"application/json"], timeout: 20)
        XCTAssertEqual(session3?.timeout, 20)
        
        // Session configuration
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        let session4 = try? Configuration(scheme: "https", host: "somehost",
                                            additionalHeaders: ["Accept-Encoding":"gzip", "Content-Type":"application/json"],
                                            timeout: 20,
                                            sessionConfiguration: configuration)
        XCTAssertEqual(session4?.sessionConfiguration.timeoutIntervalForRequest, 20)
    }
    
    func testURLRequest() {
        
        // basic request
        var session = try? Configuration(scheme: "https", host: "somehost")
        var request = try! session!.request(path: "/path", parameters: nil)

        XCTAssertEqual(request.description, "https://somehost/path")
        
        // Single parameter
        session = try? Configuration(scheme: "https", host: "somehost")
        request = try! session!.request(path: "/path", parameters: ["parameter": "value"])
        
        XCTAssertEqual(request.description, "https://somehost/path?parameter=value")
        
        // Two parameters
        session = try? Configuration(scheme: "https", host: "somehost")
        request = try! session!.request(path: "/path", parameters: ["parameter": "value", "parameter1": "value1"])
        
        // order of parameters is not guaranteed
        XCTAssertTrue(request.description == "https://somehost/path?parameter=value&parameter1=value1" || request.description == "https://somehost/path?parameter1=value1&parameter=value")
    }
}
