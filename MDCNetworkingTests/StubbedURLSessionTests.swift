//
//  StubbedNSURLSessionTests.swift
//  MDCNetworking
//
//  Created by Despotovic, Mladen on 06/01/2017.
//  Copyright © 2017 Despotovic, Mladen. All rights reserved.
//

import XCTest
@testable import MDCNetworking

class StubbedURLSessionTests: XCTestCase {
    
    var bundle: Bundle?
    
    override func setUp() {
        
        super.setUp()
        bundle = Bundle(for: type(of: self))
    }
    
    override func tearDown() {
        
        bundle = nil
        super.tearDown()
    }
    
    func test_StubbedNSURLSesssion_init() {

        let stubbedSession = StubbedURLSession()
        XCTAssertNotNil(stubbedSession)
    }
    
    func test_AddingStubbedResponse() {
        
        let stubbedSession = StubbedURLSession()
        XCTAssertEqual(stubbedSession.stubbedResponses.count, 0)
        let JSONResponse = "{ \"key\" : \"response\" }"
        stubbedSession.addStub(schema: "www",
                               host: "some1",
                               path: "/path1",
                               parameters: nil,
                               headerFields: nil,
                               response: JSONResponse,
                               responseStatusCode: 200)
        XCTAssertEqual(stubbedSession.stubbedResponses.count, 1)
        stubbedSession.addStub(schema: "www",
                               host: "some2",
                               path: "/path2",
                               parameters: nil,
                               headerFields: nil,
                               response: JSONResponse,
                               responseStatusCode: 200)
        XCTAssertEqual(stubbedSession.stubbedResponses.count, 2)
        
        stubbedSession.removeStubs()
        XCTAssertEqual(stubbedSession.stubbedResponses.count, 0)
    }
    
    func test_StubbedNSURLSesssion_SingleStubbedResponse() {
        
        let stubbedSession = StubbedURLSession()
        XCTAssertEqual(stubbedSession.stubbedResponses.count, 0)
        
        let filePath = bundle?.path(forResource: "Test1", ofType: "json")
        let responseString = try! String(contentsOfFile: filePath!, encoding: .utf8)
        stubbedSession.addStub(schema: "http",
                               host: "some1",
                               path: "/path1",
                               parameters: nil,
                               headerFields: nil,
                               response: responseString,
                               responseStatusCode: 200)

        let testExpectation = expectation(description: "Test Expectation")
        let request = URLRequest(url: URL(string: "http://some1/path1")!)
        
        let dataTask = stubbedSession.dataTask(with: request) { (data, response, error) in
            
            guard let data = data else {
                XCTAssert(true)
                return
            }
            let deserialisedResponse = try! JSONSerialization.jsonObject(with: data,
                                                                         options: JSONSerialization.ReadingOptions.allowFragments) as! [String: Any]
            let lastValue = deserialisedResponse["metricTimeInterval"] as! Int
            XCTAssertEqual(lastValue, 180)
            testExpectation.fulfill()
        }
        dataTask.resume()

        waitForExpectations(timeout: 5, handler: nil)
    }
    
    //MARK Testing `URLSessionProvider` extension
    
    func test_matchingUrlSessionProvider() {
        
        // Prepare
        let stubbedSession = StubbedURLSession()
        
        let filePath = bundle?.path(forResource: "Test1", ofType: "json")
        let responseString = try! String(contentsOfFile: filePath!, encoding: .utf8)
        stubbedSession.addStub(schema: "http",
                               host: "some1",
                               path: "/path1",
                               parameters: nil,
                               headerFields: nil,
                               response: responseString,
                               responseStatusCode: 200)
        
        let configuration = try? Configuration(scheme: "http", host: "some1")
        let client = NetworkClient(configuration: configuration!, sessionProvider: stubbedSession)
        
        // Test
        let testExpectation = expectation(description: "Test Expectation")
        
        let session = client.session(urlPath: "/path1", method: .get, parameters: nil, body: nil, session: nil) { (urlResponse, response, error, cancelled) in
            
            let responseDict = response as? [String: Any]
            let lastValue = responseDict?["metricTimeInterval"] as! Int
            XCTAssertEqual(lastValue, 180)
            testExpectation.fulfill()
        }
        try? session.start()
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func test_nonMatchingUrlSessionProvider() {
        
        // Prepare
        let stubbedSession = StubbedURLSession()
        
        let filePath = bundle?.path(forResource: "Test1", ofType: "json")
        let responseString = try! String(contentsOfFile: filePath!, encoding: .utf8)
        stubbedSession.addStub(schema: "http",
                               host: "some1",
                               path: "/path1",
                               parameters: nil,
                               headerFields: nil,
                               response: responseString,
                               responseStatusCode: 200)
        
        // Different Host: "some2"
        let configuration = try? Configuration(scheme: "http", host: "some2")
        let client = NetworkClient(configuration: configuration!, sessionProvider: stubbedSession)
        
        // Test
        let testExpectation = expectation(description: "Test Expectation")
        
        let session = client.session(urlPath: "/path1", method: .get, parameters: nil, body: nil, session: nil) { (urlResponse, response, error, cancelled) in
 
            XCTAssertNotNil(error)
            testExpectation.fulfill()
        }
        try? session.start()
        waitForExpectations(timeout: 5, handler: nil)
    }
}
