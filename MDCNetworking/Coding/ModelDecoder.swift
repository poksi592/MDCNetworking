//
//  ModelDecoder.swift
//  MDCNetworking
//
//  Created by Bartomiej Nowak on 29/01/2018.
//  Copyright © 2018 Despotovic, Mladen. All rights reserved.
//

import Foundation

struct DecodingError: Error {}

class ModelDecoder<T: Decodable> {
    
    private var decoder: DecoderProtocol
    private let serializer: JSONSerializationWrapperProtocol
    
    init(decoder: DecoderProtocol = JSONDecoder(),
         serializer: JSONSerializationWrapperProtocol = JSONSerializationWrapper()) {
        self.decoder = decoder
        self.serializer = serializer
    }
    
    func toModel(from responseObject: Any,
                 dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .iso8601) -> T? {
        
        if let jsonData = try? serializer.data(withJSONObject: responseObject, options: []) {
            return decode(jsonData: jsonData, dateDecodingStrategy: dateDecodingStrategy)
        }
        
        return nil
    }
    
    func decode(jsonData: Data,
                dateDecodingStrategy: JSONDecoder.DateDecodingStrategy) -> T? {
        decoder.dateDecodingStrategy = dateDecodingStrategy
        if let result = try? decoder.decode(T.self, from: jsonData) {
            return result
        }
        
        return nil
    }
}

protocol DecoderProtocol {
    var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy {get set}
    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable
}

extension JSONDecoder: DecoderProtocol {}
