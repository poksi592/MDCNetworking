//
//  URL+Utilities.swift
//  MDCNetworking
//
//  Created by Bartomiej Nowak on 17/01/2018.
//  Copyright © 2018 Despotovic, Mladen. All rights reserved.
//

import Foundation

extension URL {
    
    init?(
        schema: String,
        host: String,
        path: String,
        parameters: [String: String]? = nil
    ) {
        var components = URLComponents()
        
        components.scheme = schema
        components.host = host
        components.path = path
        components.queryItems = parameters?.map { key, value in URLQueryItem(name: key, value: value) }
        
        guard let url = components.url,
              let noPercentEncodingString = url.absoluteString.removingPercentEncoding,
              let noEncodingUrl = URL(string: noPercentEncodingString) else {
                return nil
        }
        
        self = noEncodingUrl
    }
}

