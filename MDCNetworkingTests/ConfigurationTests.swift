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
    
    func test_GivenDefaultValues_WhenInstantiated_ThenHasDefaultValues() {
        let config = Configuration(baseUrl: URL(string: "https://mock-host")!)
        
        XCTAssertEqual(config.httpHeaders, [:])
        XCTAssertEqual(config.timeout, 60.0)
        XCTAssertEqual(config.sessionConfiguration, .default)
        XCTAssertEqual(config.sslPinningMode, .none)
        XCTAssertNil(config.pinnedCertificates)
    }
    
    func test_GivenDefaultValues_WhenInstantiated_ThenSetTimeoutIntervalForRequest() {
        let config = Configuration(baseUrl: URL(string: "https://mock-host")!)
        
        XCTAssertEqual(config.sessionConfiguration.timeoutIntervalForRequest, 60.0)
    }
    
    func test_GivenValues_WhenInstantiated_ThenHasValues() {
        let sessionConfig = URLSessionConfiguration.ephemeral
        
        let config = Configuration(
            baseUrl: URL(string: "https://mock-host")!,
            httpHeaders: ["mock-header": "mock-value"],
            timeout: 30.0,
            sessionConfiguration: sessionConfig,
            sslPinningMode: .certificate,
            pinnedCertificates: ["mocked-string".data(using: .utf8)!]
        )
        
        XCTAssertEqual(config.httpHeaders, ["mock-header": "mock-value"])
        XCTAssertEqual(config.timeout, 30.0)
        XCTAssertEqual(config.sessionConfiguration, sessionConfig)
        XCTAssertEqual(config.sslPinningMode, .certificate)
        XCTAssertNotNil(config.pinnedCertificates)
        XCTAssertEqual(config.pinnedCertificates!, ["mocked-string".data(using: .utf8)!])
    }
    
    func test_GivenTimeout_WhenInstantiated_ThenSetTimeoutIntervalForRequest() {
        let config = Configuration(baseUrl: URL(string: "https://mock-host")!, timeout: 30.0)
        
        XCTAssertEqual(config.sessionConfiguration.timeoutIntervalForRequest, 30.0)
    }
}
