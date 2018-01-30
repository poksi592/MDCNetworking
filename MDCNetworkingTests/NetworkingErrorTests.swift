//
//  NetworkingErrorTests.swift
//  MDCNetworking
//
//  Created by Despotovic, Mladen on 16/12/2016.
//  Copyright © 2016 Despotovic, Mladen. All rights reserved.
//

import XCTest
@testable import MDCNetworking

class NetworkingErrorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testErrors400() {
        
        // Test 400
        // Prepare
        let mockedResponse400 = MockedHTTPURLResponseErrorHandling(url: URL.init(string: "https://someurl")!,
                                                                   statusCode: 400,
                                                                   httpVersion: nil,
                                                                   headerFields: nil)
        let networkError400 = NetworkError(error: nil, response: mockedResponse400!, payload: nil)
        // Test and execute
        if case .badRequest400(_, let response, _) = networkError400! {
            XCTAssertEqual(response?.statusCode, 400)
        }
        else {
            XCTAssertTrue(false, "error")
        }
        
        // Test 401
        // Prepare
        let mockedResponse401 = MockedHTTPURLResponseErrorHandling(url: URL.init(string: "https://someurl")!,
                                                                   statusCode: 401,
                                                                   httpVersion: nil,
                                                                   headerFields: nil)
        let networkError401 = NetworkError(error: nil, response: mockedResponse401!, payload: nil)
        // Test and execute
        if case .unauthorized401(_, let response, _) = networkError401! {
            XCTAssertEqual(response?.statusCode, 401)
        }
        else {
            XCTAssertTrue(false, "error")
        }
        
        // Test 403
        // Prepare
        let mockedResponse403 = MockedHTTPURLResponseErrorHandling(url: URL.init(string: "https://someurl")!,
                                                                   statusCode: 403,
                                                                   httpVersion: nil,
                                                                   headerFields: nil)
        let networkError403 = NetworkError(error: nil, response: mockedResponse403!, payload: nil)
        // Test and execute
        if case .forbidden403(_, let response, _) = networkError403! {
            XCTAssertEqual(response?.statusCode, 403)
        }
        else {
            XCTAssertTrue(false, "error")
        }
        
        // Test 404
        // Prepare
        let mockedResponse404 = MockedHTTPURLResponseErrorHandling(url: URL.init(string: "https://someurl")!,
                                                                   statusCode: 404,
                                                                   httpVersion: nil,
                                                                   headerFields: nil)
        let networkError404 = NetworkError(error: nil, response: mockedResponse404!, payload: nil)
        // Test and execute
        if case .notFound404(_, let response, _) = networkError404! {
            XCTAssertEqual(response?.statusCode, 404)
        }
        else {
            XCTAssertTrue(false, "error")
        }
    }
    
    func testErrors500() {
        
        // Test 500
        // Prepare
        let mockedResponse500 = MockedHTTPURLResponseErrorHandling(url: URL.init(string: "https://someurl")!,
                                                                   statusCode: 500,
                                                                   httpVersion: nil,
                                                                   headerFields: nil)
        let networkError500 = NetworkError(error: nil, response: mockedResponse500!, payload: nil)
        // Test and execute
        if case .serverError500(_, let response, _) = networkError500! {
            XCTAssertEqual(response?.statusCode, 500)
        }
        else {
            XCTAssertTrue(false, "error")
        }
        
        // Test 600
        // Prepare
        let mockedResponse600 = MockedHTTPURLResponseErrorHandling(url: URL.init(string: "https://someurl")!,
                                                                   statusCode: 600,
                                                                   httpVersion: nil,
                                                                   headerFields: nil)
        let networkError600 = NetworkError(error: nil, response: mockedResponse600!, payload: nil)
        // Test and execute
        guard case .other = networkError600! else {
            XCTAssertTrue(false, "error")
            return
        }
    }
    
    func testErrorsNotRecognised() {
        
        // Test -1
        // Prepare
        let mockedResponseMinusOne = MockedHTTPURLResponseErrorHandling(url: URL.init(string: "https://someurl")!,
                                                                   statusCode: -1,
                                                                   httpVersion: nil,
                                                                   headerFields: nil)
        let networkErrorMinusOne = NetworkError(error: nil, response: mockedResponseMinusOne!, payload: nil)
        // Test and execute
        guard case .other = networkErrorMinusOne! else {
            XCTAssertTrue(false, "error")
            return
        }
        
        // Test 999
        // Prepare
        let mockedResponse999 = MockedHTTPURLResponseErrorHandling(url: URL.init(string: "https://someurl")!,
                                                                   statusCode: 999,
                                                                   httpVersion: nil,
                                                                   headerFields: nil)
        let networkError999 = NetworkError(error: nil, response: mockedResponse999!, payload: nil)
        // Test and execute
        guard case .other = networkError999! else {
            XCTAssertTrue(false, "error")
            return
        }
        
    }
}




