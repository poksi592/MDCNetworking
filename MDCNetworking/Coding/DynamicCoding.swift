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
public struct DynamicKey: CodingKey {
    
    public var stringValue: String
    
    public var intValue: Int? {
        return nil
    }
    
    public init?(stringValue: String) {
        self.stringValue = stringValue
    }
    
    public init?(intValue: Int) {
        return nil
    }
}

// MARK: - Encoding

public extension UnkeyedEncodingContainer {
    
    /**
     * Recursively encodes any JSON primitive (int, bool, string, dictionary etc.). Workaround for encode having to be
     * used on concrete *Encodable* types, encoding a *[String : Any]* or *[String: Encodable]* dictionary will crash as
     * of Swift 4.
     */
    public mutating func encode(jsonValue any: Any) throws {
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

public extension KeyedEncodingContainer where Key == DynamicKey {
    
    /**
     * Recursively encodes any JSON primitive (int, bool, string, dictionary etc.). Workaround for encode having to be
     * used on concrete *Encodable* types, encoding a *[String : Any]* or *[String: Encodable]* dictionary will crash as
     * of Swift 4.
     */
    public mutating func encode(jsonValue any: Any, forKey key: DynamicKey) throws {
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

public enum FloatingPointDecodingStrategy {
    case decimal
    case double
    case float
}

public extension KeyedDecodingContainer where Key == DynamicKey {
    
    /**
     * Decodes dynamic keys with values from a JSON container.
     */
    public func decodeDynamicKeyValues(floatingPointStrategy strategy: FloatingPointDecodingStrategy) -> [String : Any] {
        var dict = [String: Any]()
        
        for key in allKeys {
            if let value = try? decode(String.self, forKey: key) {
                dict[key.stringValue] = value
            } else if let value = try? decode(Bool.self, forKey: key) {
                dict[key.stringValue] = value
            } else if var container = try? nestedUnkeyedContainer(forKey: key) {
                dict[key.stringValue] = container.decodeDynamicValues(floatingPointStrategy: strategy)
            } else if let container = try? nestedContainer(keyedBy: DynamicKey.self, forKey: key) {
                dict[key.stringValue] = container.decodeDynamicKeyValues(floatingPointStrategy: strategy)
            } else {
                var wasNumberDecoded = false
                
                switch strategy {
                    case .decimal:
                        if let value = try? decode(Decimal.self, forKey: key) {
                            dict[key.stringValue] = value
                            wasNumberDecoded = true
                        }
                    case .double:
                        if let value = try? decode(Double.self, forKey: key) {
                            dict[key.stringValue] = value
                            wasNumberDecoded = true
                        }
                    case .float:
                        if let value = try? decode(Float.self, forKey: key) {
                            dict[key.stringValue] = value
                            wasNumberDecoded = true
                        }
                }
                
                if !wasNumberDecoded {
                    if let value = try? decode(Int.self, forKey: key) {
                        dict[key.stringValue] = value
                    }
                }
            }
        }
        
        return dict
    }
}

public extension UnkeyedDecodingContainer {
    
    mutating func decodeDynamicValues(floatingPointStrategy strategy: FloatingPointDecodingStrategy) -> [Any] {
        var array = [Any]()
        
        guard let count = count else {
            return array
        }
        
        while currentIndex < count {
            if let value = try? decode(String.self) {
                array.append(value)
            } else if let value = try? decode(Bool.self) {
                array.append(value)
            } else if var container = try? nestedUnkeyedContainer() {
                array.append(container.decodeDynamicValues(floatingPointStrategy: strategy))
            } else if let container = try? nestedContainer(keyedBy: DynamicKey.self) {
                array.append(container.decodeDynamicKeyValues(floatingPointStrategy: strategy))
            } else {
                var wasNumberDecoded = false
                
                switch strategy {
                    case .decimal:
                        if let value = try? decode(Decimal.self) {
                            array.append(value)
                            wasNumberDecoded = true
                        }
                    case .double:
                        if let value = try? decode(Double.self) {
                            array.append(value)
                            wasNumberDecoded = true
                        }
                    case .float:
                        if let value = try? decode(Float.self) {
                            array.append(value)
                            wasNumberDecoded = true
                        }
                }
                
                if !wasNumberDecoded {
                    if let value = try? decode(Int.self) {
                        array.append(value)
                    }
                }
            }
        }
        
        return array
    }
}
