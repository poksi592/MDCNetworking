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
    
    func testInitialising() {
    
        // Test with default GET method
        let configuration = NetworkConfiguration(host: "http://api.timezonedb.com/")
        let session1 = JSONSession(urlPath: "https://somehost",
                                   configuration: configuration!) { (result, response, error, cancelled) in }
        XCTAssertNotNil(session1)
        guard case .get = session1.request.method else {
            XCTAssert(false, "error")
            return
        }
    }
    
    func test_CallToTimezoneAPI() {
        
        // Prepare without Configuration object set
        let expectationForTest = expectation(description: "test")
        let configuration = NetworkConfiguration(host: "http://api.timezonedb.com/")
        let parameters = ["key": "1S2RMN6YBMYA", "country": "GB", "format": "json"]
        // Execute and test
        let session1 = GenericJSONSession<ZonesResponse>(
            urlPath: "/v2/list-time-zone",
            method: .get,
            parameters: parameters,
            configuration: configuration!
        ) { response, model, error, cancelled in
                                    
            XCTAssertNil(error)
            XCTAssertFalse(cancelled)
            XCTAssertEqual(model?.zones.first?.countryCode, "GB")
            
            expectationForTest.fulfill()
        }
        XCTAssertNotNil(session1)
        session1.configuration = configuration!
        
        do {
            try session1.start()
        } catch {
            XCTFail("Session didn't start")
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    struct ZonesResponse: Decodable {
        struct CountryCode: Decodable {
            let countryCode: String
        }
        
        let zones: [CountryCode]
    }
    
    func test_InjectStubbedResponse() {
        
        // Prepare without Configuration object set
        let expectationForTest = expectation(description: "test")
        let configuration = NetworkConfiguration(host: "http://api.timezonedb.com/")
        let parameters = ["key": "1S2RMN6YBMYA", "format": "json", "country": "GB"]
        
        // Prepare stubbed session
        let stubbedSession = StubbedURLSession()
        let responseString = "{\n \"zones\":[{\"countryCode\":\"UK\"}] \n}"
        stubbedSession.addStub(fullURL:"http://api.timezonedb.com/v2/list-time-zone?key=1S2RMN6YBMYA&format=json&country=GB",
                               response:responseString)
        
        // Execute and test
        let session1 = GenericJSONSession<ZonesResponse>(
            urlPath: "/v2/list-time-zone",
            method: .get,
            parameters: parameters,
            configuration: configuration!,
            session: stubbedSession
        ) { result, model, error, cancelled in
                                    
            XCTAssertNil(error)
            XCTAssertFalse(cancelled)
            XCTAssertEqual(model?.zones.first?.countryCode, "UK")

            expectationForTest.fulfill()
        }
        XCTAssertNotNil(session1)
        session1.session = stubbedSession
        
        do {
            try session1.start()
        } catch {
            XCTFail("Session didn't start")
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func test_InjectTwoStubbedResponses() {
        
        // Prepare without Configuration object set
        let expectationForTest = expectation(description: "test")
        let configuration = NetworkConfiguration(host: "http://api.timezonedb.com/")
        let parameters = ["key": "1S2RMN6YBMYA", "format": "json", "country": "GB"]
        
        // Prepare stubbed session
        let stubbedSession = StubbedURLSession()
        let responseString = "{\n \"zones\":[{\"countryCode\":\"UK\"}] \n}"
        stubbedSession.addStub(fullURL:"http://api.timezonedb.com/v2/list-time-zone?key=1S2RMN6YBMYA&format=json&country=GB",
                               response:responseString)
        // Stubbed session with one missing parameter, therefore not valid
        stubbedSession.addStub(fullURL:"http://api.timezonedb.com/v2/list-time-zone?key=1S2RMN6YBMYA&format=json",
                               response:responseString)
        
        // Execute and test
        let session1 = GenericJSONSession<ZonesResponse>(
            urlPath: "/v2/list-time-zone",
            method: .get,
            parameters: parameters,
            configuration: configuration!,
            session: stubbedSession
        ) { response, model, error, cancelled in
                                    
            XCTAssertNil(error)
            XCTAssertFalse(cancelled)
            XCTAssertEqual(model?.zones.first?.countryCode, "UK")
            
            expectationForTest.fulfill()
        }
        XCTAssertNotNil(session1)
        session1.session = stubbedSession
        
        do {
            try session1.start()
        } catch {
            XCTFail("Could not start session.")
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func test_InjectNotValidStubbedResponse() {
        
        // Prepare without Configuration object set
        let expectationForTest = expectation(description: "test")
        let configuration = NetworkConfiguration(host: "http://api.timezonedb.com/")
        let parameters = ["key": "1S2RMN6YBMYA", "format": "json", "country": "GB"]
        
        // Prepare stubbed session
        let stubbedSession = StubbedURLSession()
        let responseString = "{\n \"zones\":[{\"countryCode\":\"UK\"}] \n}"
        // Stubbed session with one missing parameter, therefore not valid
        stubbedSession.addStub(fullURL:"http://api.timezonedb.com/v2/list-time-zone?key=1S2RMN6YBMYA&format=json",
                               response:responseString)
        
        // Execute and test
        let session1 = JSONSession(
            urlPath: "/v2/list-time-zone",
            method: .get,
            parameters: parameters,
            configuration: configuration!,
            session: stubbedSession
        ) { (response, model, error, cancelled) in
                                    
            XCTAssertNotNil(error)

            guard let error = error, case .badRequest400 = error else {
                XCTAssertTrue(false, "error")
                return
            }
            
            expectationForTest.fulfill()
        }
        XCTAssertNotNil(session1)
        
        session1.session = stubbedSession
        
        do {
            try session1.start()
        } catch {
            XCTFail("Could not start session.")
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
}


