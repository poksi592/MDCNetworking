//
//  Dictionary+Utilities.swift
//  MDCNetworking
//
//  Created by Despotovic, Mladen on 20/12/2016.
//  Copyright © 2016 Despotovic, Mladen. All rights reserved.
//

import Foundation

extension Dictionary where Key: ExpressibleByStringLiteral, Value: ExpressibleByIntegerLiteral {
    
    func URLParameters() -> String {
        
        let string = reduce("") { (currentString, currentPair) in
            let URLEncodedKey = "\(currentPair.key)".URLEncodedString()
            let URLEncodedValue = "\(currentPair.value)".URLEncodedString()
            return currentString + URLEncodedKey + "=" + URLEncodedValue + "&"
        }
        
        return String(string.dropLast())
    }
}

extension Dictionary where Key: ExpressibleByStringLiteral, Value: ExpressibleByStringLiteral {
    
    func URLParameters() -> String {
        
        let string = reduce("") { (currentString, currentPair) in
            let URLEncodedKey = "\(currentPair.key)".URLEncodedString()
            let URLEncodedValue = "\(currentPair.value)".URLEncodedString()
            return currentString + URLEncodedKey + "=" + URLEncodedValue + "&"
        }
        
        return String(string.dropLast())
    }
}



