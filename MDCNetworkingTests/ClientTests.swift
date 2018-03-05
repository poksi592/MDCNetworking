//
//  ClientTests.swift
//  MDCNetworking
//
//  Created by Despotovic, Mladen on 19/12/2016.
//  Copyright © 2016 Despotovic, Mladen. All rights reserved.
//

import XCTest
@testable import MDCNetworking

class ClientTests: XCTestCase {
    
    func testClientInitialization() {
        // Test with configuration
        let session1 = try? Configuration(scheme: "https", host: "somehost")
        let client1 = NetworkClient(configuration: session1!)
        XCTAssertNotNil(client1)
        XCTAssertNotNil(client1.configuration)
    }
}
