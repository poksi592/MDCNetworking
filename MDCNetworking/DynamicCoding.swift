//
//  DynamicCoding.swift
//  MDCNetworking
//
//  Created by Bartomiej Nowak on 04/01/2018.
//  Copyright © 2018 Despotovic, Mladen. All rights reserved.
//

import Foundation

// MARK: - DynamicKey

/**
 * Coding key that has a dynamic value.
 */
struct DynamicKey: CodingKey {
    
    var stringValue: String
    
    var intValue: Int? {
        return nil
    }
    
    init?(stringValue: String) {
        self.stringValue = stringValue
    }
    
    init?(intValue: Int) {
        return nil
    }
}

// MARK: - Encoding

extension UnkeyedEncodingContainer {
    
    /**
     * Recursively encodes any JSON primitive (int, bool, string, dictionary etc.). Workaround for encode having to be
     * used on concrete *Encodable* types, encoding a *[String : Any]* or *[String: Encodable]* dictionary will crash as
     * of Swift 4.
     */
    mutating func encode(jsonValue any: Any) throws {
        switch any {
            case let value as String:
                try encode(value)
            case let value as Int:
                try encode(value)
            case let value as Decimal:
                try encode(value)
            case let value as Double:
                try encode(value)
            case let value as Float:
                try encode(value)
            case let value as Bool:
                try encode(value)
            case let array as [Any]:
                var container = nestedUnkeyedContainer()
                
                for element in array {
                    try container.encode(jsonValue: element)
                }
            case let dictionary as [String: Any]:
                var container = nestedContainer(keyedBy: DynamicKey.self)
                
                for (key, value) in dictionary {
                    try container.encode(jsonValue: value, forKey: DynamicKey(stringValue: key)!)
                }
            default:
                assertionFailure("Type \(type(of: any)) type not supported")
        }
    }
}

extension KeyedEncodingContainer where Key == DynamicKey {
    
    /**
     * Recursively encodes any JSON primitive (int, bool, string, dictionary etc.). Workaround for encode having to be
     * used on concrete *Encodable* types, encoding a *[String : Any]* or *[String: Encodable]* dictionary will crash as
     * of Swift 4.
     */
    mutating func encode(jsonValue any: Any, forKey key: DynamicKey) throws {
        switch any {
            case let value as String:
                try encode(value, forKey: key)
            case let value as Int:
                try encode(value, forKey: key)
            case let value as Decimal:
                try encode(value, forKey: key)
            case let value as Double:
                try encode(value, forKey: key)
            case let value as Float:
                try encode(value, forKey: key)
            case let value as Bool:
                try encode(value, forKey: key)
            case let array as [Any]:
                var container = nestedUnkeyedContainer(forKey: key)
                
                for element in array {
                    try container.encode(jsonValue: element)
                }
            case let dictionary as [String: Any]:
                var container = nestedContainer(keyedBy: DynamicKey.self, forKey: key)
                
                for (dictKey, value) in dictionary {
                    try container.encode(jsonValue: value, forKey: DynamicKey(stringValue: dictKey)!)
                }
            default:
                assertionFailure("Type \(type(of: any)) type not supported")
        }
    }
}

// MARK: - Decoding

enum FloatingPointDecodingStrategy {
    case decimal
    case double
    case float
}

extension KeyedDecodingContainer where Key == DynamicKey {
    
    /**
     * Decodes dynamic keys with values from a JSON container.
     */
    func decodeDynamicKeyValues(floatingPointStrategy strategy: FloatingPointDecodingStrategy) -> [String : Any] {
        var dict = [String: Any]()
        
        for key in allKeys {
            if let value = try? decode(String.self, forKey: key) {
                dict[key.stringValue] = value
            } else if let value = try? decode(Bool.self, forKey: key) {
                dict[key.stringValue] = value
            } else if let value = try? decode(Int.self, forKey: key) {
                dict[key.stringValue] = value
            } else if let value = try? decode([Any].self, forKey: key) {
                dict[key.stringValue] = value
            } else if let value = try? decode([String: Any].self, forKey: key) {
                dict[key.stringValue] = value
            } else {
                var wasDecoded = false
                
                switch strategy {
                    case .decimal:
                        if let value = try? decode(Decimal.self, forKey: key) {
                            dict[key.stringValue] = value
                            wasDecoded = true
                        }
                    case .double:
                        if let value = try? decode(Double.self, forKey: key) {
                            dict[key.stringValue] = value
                            wasDecoded = true
                        }
                    case .float:
                        if let value = try? decode(Float.self, forKey: key) {
                            dict[key.stringValue] = value
                            wasDecoded = true
                        }
                }
                
                if !wasDecoded {
                    assertionFailure("Key \(key.stringValue) type not supported")
                }
            }
        }
        
        return dict
    }
}