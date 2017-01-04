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


typealias RequestCompletion = (Any?, HTTPURLResponse, NetworkError?, _ cancelled: Bool) -> Void

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
    var configuration: Configuration?
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
            
            completion(nil, HTTPURLResponse(), .NoConfiguration, false)
            return
        }
        
        guard let request = configuration.request(path: requestURLPath, parameters: parameters) else { return }
        let session = URLSession.init(configuration: configuration.sessionConfiguration)
        let task = session.dataTask(with: request, completionHandler: dataTaskClosure() as! (Data?, URLResponse?, Error?) -> Void)
        task.resume()
        
    }
    
    func dataTaskClosure() -> (Data?, URLResponse, Error?) -> Void {
        
        return { (data, response, error) in
            
            var responseObject: [String: String]? = nil
            var networkingError: NetworkError? = nil
            if let data = data {
                
                do {
                    
                    responseObject = try JSONSerialization.jsonObject(with: data,
                                                                      options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: String]
                }
                catch {
                    
                    networkingError = NetworkError.SerialisationFailed
                }
            }
            
            if let error = error {

                if let data = data {
                    
                    responseObject = try? JSONSerialization.jsonObject(with: data,
                                                                       options: JSONSerialization.ReadingOptions.mutableContainers) as! [String: String]
                }
                networkingError = NetworkError(error: error,
                                               response: response as! HTTPURLResponse,
                                               serverErrorPayload: responseObject)
            }
            self.completion(responseObject, response as! HTTPURLResponse, networkingError, false)
        }
    }

}

