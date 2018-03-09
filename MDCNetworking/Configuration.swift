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
    
    let baseUrl: URL
    let httpHeaders: [String: String]
    let timeout: TimeInterval
    let sessionConfiguration: URLSessionConfiguration
    let sslPinningMode: SSLPinningMode
    let pinnedCertificates: [Data]?

    public init(
        baseUrl: URL,
        httpHeaders: [String: String]? = nil,
        timeout: TimeInterval = 60,
        sessionConfiguration: URLSessionConfiguration = .default,
        sslPinningMode: SSLPinningMode = .none,
        pinnedCertificates: [Data]? = nil
    ) {
        self.baseUrl = baseUrl
        self.httpHeaders = httpHeaders ?? [:]
        self.timeout = timeout
        self.sessionConfiguration = sessionConfiguration
        self.sessionConfiguration.timeoutIntervalForRequest = timeout
        self.sslPinningMode = sslPinningMode
        self.pinnedCertificates = pinnedCertificates
    }
}

