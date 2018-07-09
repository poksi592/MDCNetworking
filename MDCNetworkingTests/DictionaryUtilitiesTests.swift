//
//  SwiftUtilitiesTests.swift
//  MDCNetworking
//
//  Created by Despotovic, Mladen on 20/12/2016.
//  Copyright © 2016 Despotovic, Mladen. All rights reserved.
//

import XCTest
@testable import MDCNetworking

class DictionaryUtilitiesTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testURLParameters() {
        
        // Empty string
        var parameters = [String : String]()
        var string = parameters.URLParameters()
        XCTAssertEqual(string, "")

        // Single parameter
        parameters = ["key": "value"]
        string = parameters.URLParameters()
        XCTAssertEqual(string, "key=value")
        
        // Two parameters, we don't have control over order sequence in result
        parameters = ["key": "value","key1": "value"]
        string = parameters.URLParameters()
        XCTAssertTrue(string == "key=value&key1=value" || string == "key1=value&key=value")
        
        // Remove % encodings if it exist and add again
        parameters = ["one%26two": "%20%3Dthree"]
        string = parameters.URLParameters()
        XCTAssertEqual(string, "one%26two=%20%3Dthree")
        
        // Add % encoding
        parameters = ["one& ": "three"]
        string = parameters.URLParameters()
        XCTAssertEqual(string, "one%26%20=three")
        
        // Test Integers as well
        var parametersInt = [String : Int]()
        parametersInt = ["key": 1]
        string = parametersInt.URLParameters()
        XCTAssertEqual(string, "key=1")
        
        // Test Floats as well
        var parametersFloat = [String : Float]()
        parametersFloat = ["key": 1.1]
        string = parametersFloat.URLParameters()
        XCTAssertEqual(string, "key=1%2E1")
        
        // Test Double as well
        var parametersDouble = [String : Double]()
        parametersDouble = ["key": 1.9384756]
        string = parametersDouble.URLParameters()
        XCTAssertEqual(string, "key=1%2E9384756")
    }
}
