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
