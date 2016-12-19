//
//  Client.swift
//  MDCNetworking
//
//  Created by Despotovic, Mladen on 19/12/2016.
//  Copyright © 2016 Despotovic, Mladen. All rights reserved.
//

import Foundation

public struct Client {
    
    fileprivate(set) var configuration: Configuration
    
    @available(*, unavailable)
    init() {
        fatalError()
    }
    
    init?(configuration: Configuration) {
        
        self.configuration = configuration
    }
}
