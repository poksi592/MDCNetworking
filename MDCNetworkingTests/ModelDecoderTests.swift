//
//  ModelDecoderTests.swift
//  MDCNetworkingTests
//
//  Created by Bartomiej Nowak on 29/01/2018.
//  Copyright © 2018 Despotovic, Mladen. All rights reserved.
//

import XCTest
@testable import MDCNetworking

final class ModelDecoderTests: XCTestCase {
    
    var mockedSerializer: MockSerializer!
    private var mockedDecoder: MockDecoder!
    private var decoder: ModelDecoder<MockDecoder.DummyCodable>!
    
    override func setUp() {
        super.setUp()
        
        mockedSerializer = MockSerializer()
        mockedDecoder = MockDecoder()
        decoder = ModelDecoder<MockDecoder.DummyCodable>(decoder: mockedDecoder,
                                                         serializer: mockedSerializer)
    }
    
    override func tearDown() {
        mockedSerializer = nil
        mockedDecoder = nil
        decoder = nil
        
        super.tearDown()
    }
    
    func test_WhenDecodeToModel_ThenDefaultDateDecodingOptionIsISO8601() {
        mockedSerializer.shouldThrow = false
        mockedDecoder.shouldThrow = false
        _ = decoder.toModel(from: ["":""])
        
        guard case .iso8601 = mockedDecoder.dateDecodingStrategy else {
            return XCTFail("Date decoding strategy not set to ISO8601")
        }
    }
    
    func test_GivenDateStrategyDeferredToDate_WhenDecodeToModel_ThenDateStrategyIsChangedToDeferredToDate() {
        mockedSerializer.shouldThrow = false
        mockedDecoder.shouldThrow = false
        _ = decoder.toModel(from: [:], dateDecodingStrategy: .deferredToDate)
        
        guard case .deferredToDate = mockedDecoder.dateDecodingStrategy else {
            return XCTFail("Date decoding strategy not set to deferredToDate")
        }
    }
    
    func test_GivenDecoderAndSerializerDoNotThrow_WhenDecodeToModel_ThenReturnObject() {
        
        mockedSerializer.shouldThrow = false
        mockedDecoder.shouldThrow = false
        
        XCTAssertNotNil(decoder.toModel(from: ["" :""]))
    }
    
    func test_GivenDecoderThrows_WhenDecodeToModel_ThenReturnNil() {
        
        mockedSerializer.shouldThrow = false
        mockedDecoder.shouldThrow = true
        
        XCTAssertNil(decoder.toModel(from: ["":""]))
    }
    
    func test_GivenSerializerThrows_WhenDecodeToModel_ThenReturnNil() {
        
        mockedSerializer.shouldThrow = true
        mockedDecoder.shouldThrow = false
        
        XCTAssertNil(decoder.toModel(from: ["":""]))
    }
}

private final class MockDecoder: DecoderProtocol {
    var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .millisecondsSince1970
    
    struct DummyCodable: Codable { }
    var shouldThrow: Bool?
    
    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        
        if shouldThrow == false {
            return DummyCodable() as! T
        }
        
        throw MockSerializer.DummyError()
    }
}
