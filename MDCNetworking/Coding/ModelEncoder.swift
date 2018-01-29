//
//  ModelEncoder.swift
//  MDCNetworking
//
//  Created by Bartomiej Nowak on 29/01/2018.
//  Copyright © 2018 Despotovic, Mladen. All rights reserved.
//

import Foundation

struct ModelEncoder {
    private let encoder: EncoderProtocol
    private let serializer: JSONSerializationWrapperProtocol
    
    init(encoder: EncoderProtocol = JSONEncoder(),
         serializer: JSONSerializationWrapperProtocol = JSONSerializationWrapper()) {
        
        self.encoder = encoder
        self.serializer = serializer
    }
    
    func toJSON<T: Codable>(from model: T) -> Any? {
        
        if let encodedJSONData = try? encoder.encode(model) {
            return serialize(data: encodedJSONData)
        }
        
        return nil
    }
    
    private func serialize(data: Data) -> Any? {
        
        if let jsonObject = try? serializer.jsonObject(with: data, options: []) {
            return jsonObject
        }
        return nil
    }
}

protocol EncoderProtocol {
    func encode<T>(_ value: T) throws -> Data where T : Encodable
}

extension JSONEncoder: EncoderProtocol {}

protocol JSONSerializationWrapperProtocol {
    func jsonObject(with data: Data, options opt: JSONSerialization.ReadingOptions) throws -> Any
    func data(withJSONObject obj: Any, options opt: JSONSerialization.WritingOptions) throws -> Data
}

struct JSONSerializationWrapper: JSONSerializationWrapperProtocol {
    func jsonObject(with data: Data, options opt: JSONSerialization.ReadingOptions) throws -> Any {
        return try JSONSerialization.jsonObject(with:data)
    }
    
    func data(withJSONObject obj: Any, options opt: JSONSerialization.WritingOptions = []) throws -> Data {
        return try JSONSerialization.data(withJSONObject: obj, options: opt)
    }
}
