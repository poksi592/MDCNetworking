//
//  Configuration.swift
//  MDCNetworking
//
//  Created by Despotovic, Mladen on 19/12/2016.
//  Copyright © 2016 Despotovic, Mladen. All rights reserved.
//

import Foundation

public struct Configuration {
    
    public struct UrlConstructionError: Error {}
    public struct PathPercentEncodingError: Error {}

    private (set) var host: URL
    private (set) var additionalHeaders: [String:String]
    private (set) var timeout: TimeInterval
    private (set) var sessionConfiguration: URLSessionConfiguration
    private (set) var certificatesPathsForResource: [String]?
    
    @available(*, unavailable)
    init() {
        fatalError()
    }
    
    public init?(
        host: String,
        additionalHeaders: [String: String]? = nil,
        timeout: TimeInterval = 60,
        sessionConfiguration: URLSessionConfiguration = .default,
        certificatesPathsForResource: [String]? = nil
    ) {
        guard let host = URL(string: host) else {
            return nil
        }
        
        self.host = host
        self.additionalHeaders = additionalHeaders ?? [:]
        self.timeout = timeout
        self.sessionConfiguration = sessionConfiguration
        self.sessionConfiguration.timeoutIntervalForRequest = timeout
        self.certificatesPathsForResource = certificatesPathsForResource
    }
    
    func request(path: String, parameters: [String: String]?) throws -> URLRequest {
        
        guard let percentEncodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            throw PathPercentEncodingError()
        }
        
        let expandedPath: String
        if let parametersString = parameters?.URLParameters() {
            expandedPath = percentEncodedPath + "?" + parametersString
        } else {
            expandedPath = percentEncodedPath
        }
        
        guard let requestURL = URL(string: expandedPath, relativeTo: host) else {
            throw UrlConstructionError()
        }
        
        var request = URLRequest(url: requestURL)
        
        for (key, value) in additionalHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        return request
    }
}

