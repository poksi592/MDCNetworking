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
        stubbedSession.addStub(fullURL:"http://someaddress", response:JSONResponse)
        XCTAssertEqual(stubbedSession.stubbedResponses.count, 1)
        stubbedSession.addStub(fullURL:"http://someaddress1", response:JSONResponse)
        XCTAssertEqual(stubbedSession.stubbedResponses.count, 2)
        
        stubbedSession.removeStubs()
        XCTAssertEqual(stubbedSession.stubbedResponses.count, 0)
    }
    
    func test_StubbedNSURLSesssion_SingleStubbedResponse() {
        
        let stubbedSession = StubbedURLSession()
        XCTAssertEqual(stubbedSession.stubbedResponses.count, 0)
        
        let filePath = bundle?.path(forResource: "Test1", ofType: "json")
        let responseString = try! String(contentsOfFile: filePath!, encoding: .utf8)
        stubbedSession.addStub(fullURL:"http://someaddress", response:responseString)

        let testExpectation = expectation(description: "Test Expectation")
        let request = URLRequest(url: URL(string: "http://someaddress")!)
        
        let dataTask = stubbedSession.dataTask(with: request) { (data, response, error) in
            
            XCTAssertNotNil(data)
            let deserialisedResponse = try! JSONSerialization.jsonObject(with: data!,
                                                                         options: JSONSerialization.ReadingOptions.allowFragments) as! [String: Any]
            let lastValue = deserialisedResponse["metricTimeInterval"] as! Int
            XCTAssertEqual(lastValue, 180)
            testExpectation.fulfill()
        }
        dataTask.resume()

        waitForExpectations(timeout: 5, handler: nil)
    }
    
}
