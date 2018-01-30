//
//  ModelEncoderTests.swift
//  MDCNetworkingTests
//
//  Created by Bartomiej Nowak on 29/01/2018.
//  Copyright © 2018 Despotovic, Mladen. All rights reserved.
//

import XCTest
@testable import MDCNetworking

final class ModelEncoderTests: XCTestCase {
    fileprivate var mockedEncoder: MockEncoder!
    fileprivate var mockedSerializer: MockSerializer!
    fileprivate var encoder: ModelEncoder!
    
    override func setUp() {
        super.setUp()
        
        mockedEncoder = MockEncoder()
        mockedSerializer = MockSerializer()
        encoder = ModelEncoder(encoder: mockedEncoder, serializer: mockedSerializer)
    }
    
    override func tearDown() {
        
        mockedEncoder = nil
        mockedSerializer = nil
        encoder = nil
        
        super.tearDown()
    }
    
    func test_GivenEncoderAndSerializerDoNotThrow_WhenEncodeToJSON_ThenReturnObject() {
        
        mockedEncoder.shouldThrow = false
        mockedSerializer.shouldThrow = false
        
        XCTAssertNotNil(encoder.toJSON(from: [MockEncoder.DummyCodable()]))
    }
    
    func test_GivenEncoderThrows_WhenEncodeToJSON_ThenReturnNil() {
        
        mockedEncoder.shouldThrow = true
        mockedSerializer.shouldThrow = false
        
        XCTAssertNil(encoder.toJSON(from: [MockEncoder.DummyCodable()]))
    }
    
    func test_GivenSerializerThrows_WhenEncodeToJSON_ThenReturnNil() {
        
        mockedEncoder.shouldThrow = false
        mockedSerializer.shouldThrow = true
        
        XCTAssertNil(encoder.toJSON(from: [MockEncoder.DummyCodable()]))
    }
}

private final class MockEncoder: EncoderProtocol {
    struct DummyCodable: Codable { }
    var shouldThrow: Bool?
    
    func encode<T>(_ value: T) throws -> Data where T : Encodable {
        
        if shouldThrow == false {
            return Data()
        }
        
        throw MockSerializer.DummyError()
    }
}
