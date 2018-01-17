//
//  PactStubbedURLSession.swift
//  MDCNetworking
//
//  Created by Bartomiej Nowak on 17/01/2018.
//  Copyright © 2018 Despotovic, Mladen. All rights reserved.
//

import Foundation

public class PactStubbedURLSession: URLSession {
    
    private (set) var response: Data
    private (set) var urlResponse: URLResponse
    
    public init(response: Data, urlResponse: URLResponse) {
        
        self.response = response
        self.urlResponse = urlResponse
    }
    
    override public func dataTask(
        with: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTask {
        
        completionHandler(response, urlResponse, nil)
        
        return PactURLSessionDataTask()
    }
    
}

private class PactURLSessionDataTask: URLSessionDataTask {
    public override func resume() {}
}

