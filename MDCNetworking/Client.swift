//
//  Client.swift
//  MDCNetworking
//
//  Created by Despotovic, Mladen on 19/12/2016.
//  Copyright © 2016 Despotovic, Mladen. All rights reserved.
//

import Foundation

public struct Client {
    
    enum RequestMethod {
        
        case GET, POST
    }
    
    fileprivate(set) var configuration: SessionConfiguration
    fileprivate(set) var method: RequestMethod
    fileprivate(set) var parameters: [String:String]?
    
    @available(*, unavailable)
    init() {
        fatalError()
    }
    
    init?(configuration: SessionConfiguration,
          method: RequestMethod = .GET,
          parameters: [String:String]? = nil) {
        
        self.configuration = configuration
        self.method = method
        self.parameters = parameters
    }
}
