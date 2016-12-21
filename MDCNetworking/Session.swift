//
//  Session.swift
//  MDCNetworking
//
//  Created by Despotovic, Mladen on 19/12/2016.
//  Copyright © 2016 Despotovic, Mladen. All rights reserved.
//

import Foundation

enum HTTPMethodName: String {
    
    case GET = "GET"
    case POST = "POST"
}


typealias RequestCompletion = (Any?, URLResponse, NetworkError?, _ cancelled: Bool) -> Void

protocol CancelableSession {
    
    var completion: RequestCompletion { get set }
    var configuration: Configuration? { get set }
    var requestURLPath: String { get set }
    var HTTPMethod: HTTPMethodName { get set }
    var additionalHeaders: [String:String] { get set }
    var parameters: [String: String] { get set }
    
    init(requestURLPath: String,
          HTTPMethod: HTTPMethodName,
          parameters: [String: String]?,
          completion: @escaping RequestCompletion)
    
    func start()
}

struct JSONSession: CancelableSession {
    
    internal(set) var completion: RequestCompletion
    internal(set) var configuration: Configuration?
    internal(set) var requestURLPath: String
    internal(set) var HTTPMethod: HTTPMethodName
    internal(set) var additionalHeaders: [String:String] = [:]
    internal(set) var parameters: [String: String] = [:]
    
    @available(*, unavailable)
    init() {
        fatalError()
    }
    
    init(requestURLPath: String,
         HTTPMethod: HTTPMethodName = .GET,
         parameters: [String: String]? = nil,
         completion: @escaping RequestCompletion) {
        
        self.requestURLPath = requestURLPath
        self.HTTPMethod = HTTPMethod
        self.configuration = nil
        self.completion = completion
        if let parameters = parameters {
            
            self.parameters = parameters
        }
        self.additionalHeaders = ["Content-Type":"application/json"]
    }
    
    func start() {
        
        guard let configuration = configuration else {
            
            completion(nil, URLResponse(), .NoConfiguration, false)
            return
        }
        
        guard let request = configuration.request(path: requestURLPath, parameters: parameters) else { return }
        let session = URLSession.init(configuration: configuration.sessionConfiguration)
        let task = session.dataTask(with: request) { (data, response, error) in
            
        }
        
    }
}




/*
 //    var sessionRequest:URLRequest? {get}
 var configuration: Configuration {get}
 var sessionConfiguration:URLSessionConfiguration {get}
 var session:URLSession? {get}
 
 init(URL:URL,
 paramNetworkingConfiguration:NetworkingConfiguration,
 paramHTTPMethodString:HTTPMethodName,
 paramRequestParamaters:Dictionary<String,String>?,
 paramCompletionClosure:RequestCompletion,
 paramProgressClosure:RequestProgress?)
 
 func setHeaders(_ headers:Dictionary<String,String>) -> ()
 func cancel() -> ()
 func startSession() -> ()


fileprivate(set) var method: HTTPMethodName
fileprivate(set) var parameters: [String:String]?


method: HTTPMethodName = .GET,
parameters: [String:String]? = nil

self.method = method
self.parameters = parameters
 
 */

