//
//  String+Utilities.swift
//  MDCNetworking
//
//  Created by Despotovic, Mladen on 20/12/2016.
//  Copyright © 2016 Despotovic, Mladen. All rights reserved.
//

import Foundation

extension String {
    
    func URLEncodedString() -> String {
        return removingPercentEncoding?.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics) ?? ""
    }
}
