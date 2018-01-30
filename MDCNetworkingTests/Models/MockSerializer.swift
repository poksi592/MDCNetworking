//
//  MockSerializer.swift
//  MDCNetworkingTests
//
//  Created by Bartomiej Nowak on 29/01/2018.
//  Copyright © 2018 Despotovic, Mladen. All rights reserved.
//

import Foundation
@testable import MDCNetworking

final class MockSerializer: JSONSerializationWrapperProtocol {
    
    struct DummyError: Error {}
    
    var stubbedResponse: Any?
    var shouldThrow: Bool?
    
    func jsonObject(with data: Data, options opt: JSONSerialization.ReadingOptions) throws -> Any {
        if shouldThrow == false {
            return ["" : ""]
        }
        
        throw DummyError()
    }
    
    func data(withJSONObject obj: Any, options opt: JSONSerialization.WritingOptions) throws -> Data {
        if shouldThrow == false {
            return Data()
        }
        
        throw DummyError()
    }
}

