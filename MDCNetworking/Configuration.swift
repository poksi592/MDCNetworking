//
//  Configuration.swift
//  MDCNetworking
//
//  Created by Despotovic, Mladen on 19/12/2016.
//  Copyright © 2016 Despotovic, Mladen. All rights reserved.
//

import Foundation

public struct Configuration {

    fileprivate(set) var host: URL
    fileprivate(set) var additionalHeaders: [String:String]
    fileprivate(set) var timeout: TimeInterval
    fileprivate(set) var sessionConfiguration: URLSessionConfiguration
    
    @available(*, unavailable)
    init() {
        fatalError()
    }
    
    init?(host: String,
          additionalHeaders: [String:String]? = nil,
          timeout: TimeInterval = 60,
          sessionConfiguration: URLSessionConfiguration = URLSessionConfiguration.default) {
        
        guard let host = URL(string: host) else { return nil }
        self.host = host
        self.additionalHeaders = additionalHeaders ?? [:]
        self.timeout = timeout
        self.sessionConfiguration = sessionConfiguration
        self.sessionConfiguration.timeoutIntervalForRequest = self.timeout
    }
}

public extension Configuration {
    
    func request(path: String, parameters: [String : String]?) -> URLRequest? {
        
        let fullMethodPath: String
        if let parametersString = parameters?.URLParameters() {
            
            fullMethodPath = path + "?" + parametersString
        }
        else {
            
            fullMethodPath = path
        }
        guard let requestURL = URL.init(string: fullMethodPath, relativeTo: host) else { return nil }
        
        let request = URLRequest(url: requestURL)
        return request
    }
}

