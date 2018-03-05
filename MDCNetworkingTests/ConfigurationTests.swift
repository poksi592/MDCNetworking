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
    
    // MARK: - Initialization
    
    func test_Initialization_DefaultValues() {
        guard let configuration = try? Configuration(scheme: "https", host: "mock-host") else {
            XCTFail("Failed to initialize configuration.")
            return
        }
        
        XCTAssertEqual(configuration.baseUrl.scheme, "https")
        XCTAssertEqual(configuration.baseUrl.host, "mock-host")
        XCTAssertTrue(configuration.additionalHeaders.isEmpty)
        XCTAssertEqual(configuration.sessionConfiguration, .default)
    }
    
    func test_Initialization() {
        let customConfiguration = URLSessionConfiguration.ephemeral
        
        customConfiguration.timeoutIntervalForRequest = 33
        
        guard
            let configuration = try? Configuration(
                scheme: "https",
                host: "mock-host",
                additionalHeaders: ["Accept-Encoding":"gzip", "Content-Type":"application/json"],
                sessionConfiguration: customConfiguration,
                sslPinningMode: .certificate,
                pinnedCertificates: ["mock-data".data(using: .utf8)!]
            ),
            let pinnedCerts = configuration.pinnedCertificates
        else {
            XCTFail("Failed to initialize configuration.")
            return
        }
        
        XCTAssertEqual(configuration.baseUrl.scheme, "https")
        XCTAssertEqual(configuration.baseUrl.host, "mock-host")
        XCTAssertEqual(configuration.additionalHeaders.count, 2)
        XCTAssertEqual(configuration.sessionConfiguration.timeoutIntervalForRequest, 33)
        XCTAssertEqual(configuration.sslPinningMode, .certificate)
        XCTAssertEqual(pinnedCerts, ["mock-data".data(using: .utf8)!])
    }
    
    // MARK: - Requests
    
    func test_URLRequest() {
        do {
            let configuration = try Configuration(scheme: "https", host: "mock-host")
            let request = try configuration.request(path: "/mock-path", parameters: nil)
            
            XCTAssertEqual(request.url?.scheme, "https")
            XCTAssertEqual(request.url?.host, "mock-host")
            XCTAssertEqual(request.url?.path, "/mock-path")
            XCTAssertEqual(request.url?.query, "")
        } catch {
            XCTFail("Failed to initialize configuration or request with error: \(error)")
        }
    }
    
    func test_URLRequest_MissingSlashInPath_ShouldBeCorrected() {
        do {
            let configuration = try Configuration(scheme: "https", host: "mock-host")
            let request = try configuration.request(path: "mock-path", parameters: nil)
            
            XCTAssertEqual(request.url?.scheme, "https")
            XCTAssertEqual(request.url?.host, "mock-host")
            XCTAssertEqual(request.url?.path, "/mock-path")
            XCTAssertEqual(request.url?.query, "")
        } catch {
            XCTFail("Failed to initialize configuration or request with error: \(error)")
        }
    }
    
    func test_URLRequest_QueryItems() {
        do {
            let configuration = try Configuration(scheme: "https", host: "mock-host")
            let request = try configuration.request(
                path: "/mock-path",
                parameters: ["mock-param" : "mock-value", "mock-param-2" : "mock-value-2"]
            )
            
            XCTAssertEqual(request.url?.scheme, "https")
            XCTAssertEqual(request.url?.host, "mock-host")
            XCTAssertEqual(request.url?.path, "/mock-path")
            XCTAssertTrue(request.url?.query?.contains("mock-param=mock-value") ?? false)
            XCTAssertTrue(request.url?.query?.contains("mock-param-2=mock-value-2") ?? false)
        } catch {
            XCTFail("Failed to initialize configuration or request with error: \(error)")
        }
    }
    
    func test_URLRequest_AdditionalHeaders() {
        do {
            let configuration = try Configuration(
                scheme: "https",
                host: "mock-host",
                additionalHeaders: ["mock-header": "mock-value", "mock-header-2": "mock-value-2"]
            )
            let request = try configuration.request(path: "/mock-path", parameters: nil)
            
            XCTAssertEqual(request.url?.scheme, "https")
            XCTAssertEqual(request.url?.host, "mock-host")
            XCTAssertEqual(request.url?.path, "/mock-path")
            XCTAssertEqual(request.value(forHTTPHeaderField: "mock-header"), "mock-value")
            XCTAssertEqual(request.value(forHTTPHeaderField: "mock-header-2"), "mock-value-2")
        } catch {
            XCTFail("Failed to initialize configuration or request with error: \(error)")
        }
    }
}
