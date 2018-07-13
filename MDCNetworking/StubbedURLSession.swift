//
//  StubbedURLSesssion.swift
//  MDCNetworking
//
//  Created by Despotovic, Mladen on 06/01/2017.
//  Copyright © 2017 Despotovic, Mladen. All rights reserved.
//

import Foundation

/**
 StubbedURLSession provides possibility to be either used as a stubbed session directly in
 `NetworkClient.session(...)` function, or it can be used as an `URLSessionProvider`
 and thus implementing more possibilities
 
 It can be used as an out of the box solution to stub the responses matching certain requests,
 or developers can create their separate implementation of `URLSessionProvider` and its sole
 function `session(for urlRequest: URLRequest) -> URLSession?`
 */
public class StubbedURLSession: URLSession {

    public var stubbedResponses = [URLRequest: Dictionary<HTTPURLResponse, Data>]()
    
    override public func dataTask(with: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {

        if let response = stubbedResponses[with],
            let responseAndData = response.first {
            
            completionHandler(responseAndData.value, responseAndData.key, nil)
        }
        else {
            
            let mockedResponse = MockedHTTPURLResponseErrorHandling(url: with.url!,
                                                                    statusCode: 400,
                                                                    httpVersion: nil,
                                                                    headerFields: nil)
            completionHandler(nil, mockedResponse, NetworkError(error: nil,
                                                                response: mockedResponse,
                                                                payload: nil))
        }

        return MockURLSessionDataTask()
    }
    
    // MARK Safer overload of the 'addStub' above, because it creates URL in the same way
    // and makes the order of parameters in URL same
    func addStub(schema: String,
                 host: String,
                 path: String,
                 parameters: [String: String]?,
                 headerFields: [String: String]?,
                 response: String,
                 responseStatusCode: Int) {
        
        if let fullUrl = URL(schema: schema,
                          host: host,
                          path: path,
                          parameters: parameters),
            let urlResponse = HTTPURLResponse(url: fullUrl,
                                              statusCode: responseStatusCode,
                                              httpVersion: nil,
                                              headerFields: headerFields),
            let response = response.data(using: .utf8) {
            
            let urlRequest = URLRequest(url: fullUrl)
            stubbedResponses[urlRequest] = [urlResponse: response]
        }
    }
    
    func removeStubs() {
        
        stubbedResponses = [:]
    }
        
}

extension StubbedURLSession: URLSessionProvider {
    
    public func session(for urlRequest: URLRequest) -> URLSession? {
        
        if let _ = stubbedResponses[urlRequest] {
            return self
        }
        return nil
    }
}

fileprivate class MockURLSessionDataTask: URLSessionDataTask {
    
    public override func resume() {
        
    }
}

class MockedHTTPURLResponseErrorHandling: HTTPURLResponse {
    
    var mockedStatusCode: Int
    
    override init?(url: URL, statusCode: Int, httpVersion HTTPVersion: String?, headerFields: [String : String]?) {
        
        self.mockedStatusCode = statusCode
        super.init(url: url, mimeType: "Not necessary", expectedContentLength: 10, textEncodingName: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var statusCode:Int  {
        
        return mockedStatusCode
    }
}
