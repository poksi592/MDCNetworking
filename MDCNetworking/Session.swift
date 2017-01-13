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


typealias RequestCompletion = (Any?, HTTPURLResponse?, NetworkError?, _ cancelled: Bool) -> Void
typealias DataTaskClosure = (Data?, URLResponse?, Error?) -> Void

protocol CancelableSession {
    
    var completion: RequestCompletion { get set }
    var configuration: Configuration { get set }
    var requestURLPath: String { get set }
    var HTTPMethod: HTTPMethodName { get set }
    var additionalHeaders: [String:String] { get set }
    var parameters: [String: String]? { get set }
    var session: URLSession? { get set }
    
    init(requestURLPath: String,
          HTTPMethod: HTTPMethodName,
          parameters: [String: String]?,
          configuration: Configuration,
          session: URLSession?,
          completion: @escaping RequestCompletion)
    
    mutating func start()
    func cancel()
    func dataTaskClosure() -> DataTaskClosure
}

extension CancelableSession {
    
    mutating func start() {
        
        guard let request = configuration.request(path: requestURLPath, parameters: parameters) else { return }
        if session == nil {
            
            session = URLSession.init(configuration: configuration.sessionConfiguration)
        }
        let task = session?.dataTask(with: request, completionHandler: dataTaskClosure())
        task?.resume()
    }
    
    func cancel() -> () {
        
        if let session = session {

            session.invalidateAndCancel()
            completion(nil, HTTPURLResponse(), .TaskCancelled, false)
        }
    }
}

struct JSONSession: CancelableSession {
    
    internal(set) var completion: RequestCompletion
    internal(set) var configuration: Configuration
    internal(set) var requestURLPath: String
    internal(set) var HTTPMethod: HTTPMethodName
    internal(set) var additionalHeaders: [String:String] = [:]
    internal(set) var parameters: [String: String]? = nil
    internal(set) var session: URLSession? = nil
    
    @available(*, unavailable)
    init() {
        fatalError()
    }
    
    init(requestURLPath: String,
         HTTPMethod: HTTPMethodName = .GET,
         parameters: [String: String]? = nil,
         configuration: Configuration,
         session: URLSession? = nil,
         completion: @escaping RequestCompletion) {
        
        self.requestURLPath = requestURLPath
        self.HTTPMethod = HTTPMethod
        self.completion = completion
        self.configuration = configuration
        self.session = session
        if let parameters = parameters {
            
            self.parameters = parameters
        }
        self.additionalHeaders = ["Content-Type":"application/json"]
    }
    
    func dataTaskClosure() -> (Data?, URLResponse?, Error?) -> Void {
        
        return { (data, response, error) in
            
            var responseObject: [String: Any]? = nil
            var networkingError: NetworkError? = nil
            if let data = data {
                
                do {
                    
                    responseObject = try JSONSerialization.jsonObject(with: data,
                                                                      options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any]
                }
                catch {
                    
                    networkingError = NetworkError.SerialisationFailed
                }
            }
            
            if let error = error {

                if let data = data {
                    
                    responseObject = try? JSONSerialization.jsonObject(with: data,
                                                                       options: JSONSerialization.ReadingOptions.mutableContainers) as! [String: Any]
                }
                networkingError = NetworkError(error: error,
                                               response: response as? HTTPURLResponse,
                                               serverErrorPayload: responseObject)
            }
            self.completion(responseObject, response as? HTTPURLResponse, networkingError, false)
        }
    }

}

