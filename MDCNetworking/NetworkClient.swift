//
//  NetworkClient.swift
//  MDCNetworking
//
//  Created by Despotovic, Mladen on 19/12/2016.
//  Copyright © 2016 Despotovic, Mladen. All rights reserved.
//

import Foundation

open class NetworkClient {
    
    open private (set) var configuration: NetworkConfiguration
    
    public init(configuration: NetworkConfiguration) {
        self.configuration = configuration
    }
}
