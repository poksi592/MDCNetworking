//
//  NetworkClient.swift
//  MDCNetworking
//
//  Created by Despotovic, Mladen on 19/12/2016.
//  Copyright © 2016 Despotovic, Mladen. All rights reserved.
//

import Foundation

public struct NetworkClient {
    
    fileprivate(set) var configuration: NetworkConfiguration
    
    @available(*, unavailable)
    init() {
        fatalError()
    }
    
    init?(configuration: NetworkConfiguration) {
        
        self.configuration = configuration
    }
}
