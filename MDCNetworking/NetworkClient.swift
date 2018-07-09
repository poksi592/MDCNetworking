//
//  NetworkClient.swift
//  MDCNetworking
//
//  Created by Despotovic, Mladen on 19/12/2016.
//  Copyright © 2016 Despotovic, Mladen. All rights reserved.
//

import Foundation

open class NetworkClient {

    open let configuration: Configuration
    open let sessionProvider: URLSessionProvider?
    
    public init(configuration: Configuration, sessionProvider: URLSessionProvider?) {
        self.configuration = configuration
        self.sessionProvider = sessionProvider
    }
    
    open func session(
        urlPath: String,
        method: HTTPMethod = .get,
        parameters: [String: String]? = nil,
        body: Data? = nil,
        session: URLSession? = nil,
        completion: @escaping ResponseCallback
    ) -> HTTPJSONSession {
        
        let session = HTTPJSONSession(
            urlPath: urlPath,
            method: method,
            parameters: parameters,
            body: body,
            configuration: configuration,
            session: session,
            completion: completion
        )
        
        session.sessionProvider = sessionProvider
        
        return session
    }
}
