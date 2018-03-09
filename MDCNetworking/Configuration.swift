//
//  Configuration.swift
//  MDCNetworking
//
//  Created by Despotovic, Mladen on 19/12/2016.
//  Copyright © 2016 Despotovic, Mladen. All rights reserved.
//

import Foundation

public enum SSLPinningMode {
    case none
    case certificate
}

public struct Configuration {
    
    public struct InvalidBaseUrl: Error {}
    public struct UrlConstructionError: Error {}
    public struct PathPercentEncodingError: Error {}

    let baseUrl: URL
    let additionalHeaders: [String: String]
    let timeout: TimeInterval
    let sessionConfiguration: URLSessionConfiguration
    let sslPinningMode: SSLPinningMode
    let pinnedCertificates: [Data]?

    public init(
        baseUrl: URL,
        additionalHeaders: [String: String]? = nil,
        timeout: TimeInterval = 60,
        sessionConfiguration: URLSessionConfiguration = .default,
        sslPinningMode: SSLPinningMode = .none,
        pinnedCertificates: [Data]? = nil
    ) {
        self.baseUrl = baseUrl
        self.additionalHeaders = additionalHeaders ?? [:]
        self.timeout = timeout
        self.sessionConfiguration = sessionConfiguration
        self.sessionConfiguration.timeoutIntervalForRequest = timeout
        self.sslPinningMode = sslPinningMode
        self.pinnedCertificates = pinnedCertificates
    }
    
    func request(path: String, parameters: [String: String]?) throws -> URLRequest {
        
        var mutablePath = path
        
        if mutablePath.first != "/" {
            mutablePath.insert("/", at: mutablePath.startIndex)
        }
        
        guard var components = URLComponents(url: baseUrl, resolvingAgainstBaseURL: true) else {
            throw InvalidBaseUrl()
        }
        
        components.path = baseUrl.path + mutablePath
        
        if let parameters = parameters {
            components.queryItems = parameters.flatMap(URLQueryItem.init)
        }
        
        guard let requestUrl = components.url else {
            throw UrlConstructionError()
        }
        
        var request = URLRequest(url: requestUrl)
        
        additionalHeaders.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        return request
    }
}

