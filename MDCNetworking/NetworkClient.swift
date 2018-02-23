//
//  NetworkClient.swift
//  MDCNetworking
//
//  Created by Despotovic, Mladen on 19/12/2016.
//  Copyright © 2016 Despotovic, Mladen. All rights reserved.
//

import Foundation

public protocol NetworkClientInterface {
    func session(
        path: String,
        method: HTTPMethod,
        parameters: [String: String]?,
        body: Data?,
        additionalHeaderFields: [String: String]?,
        session: URLSession?,
        completion: @escaping ResponseCallback
    ) throws -> HTTPSession
}

open class NetworkClient: NetworkClientInterface {

    open let configuration: Configuration
    
    public init(configuration: Configuration) {
        self.configuration = configuration
    }

    /**
     * Creates a HTTP session based on provided configuration.
     */
    open func session(
        path: String,
        method: HTTPMethod = .get,
        parameters: [String: String]? = nil,
        body: Data? = nil,
        additionalHeaderFields: [String: String]? = nil,
        session: URLSession? = nil,
        completion: @escaping ResponseCallback
    ) -> HTTPSession {
        
        let session = HTTPSession(
            path: path,
            method: method,
            parameters: parameters,
            body: body,
            configuration: configuration,
            session: session,
            completion: completion
        )
        
        session.request.additionalHeaderFields = additionalHeaderFields
        
        return session
    }
}
