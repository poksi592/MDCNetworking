//
//  StubbedURLSesssion.swift
//  MDCNetworking
//
//  Created by Despotovic, Mladen on 06/01/2017.
//  Copyright © 2017 Despotovic, Mladen. All rights reserved.
//

import Foundation

public class StubbedURLSession: URLSession {
    
    public var stubbedResponses: [String: String] = [:]
    
    override public func dataTask(with: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        
        let filteredResponses = stubbedResponses.filter { (response) in
            
            guard let stubbedURL = URL(string: response.key) else {
                return false
            }
            return URLRequest(url: stubbedURL) == with
        }
        
        if let firstResponse = filteredResponses.first?.value  {
            
            completionHandler(firstResponse.data(using: .utf8), nil, nil)
        }
        else {
            
            let mockedResponse = MockedHTTPURLResponseErrorHandling(url: with.url!,
                                                                    statusCode: 400,
                                                                    httpVersion: nil,
                                                                    headerFields: nil)
            completionHandler(nil, mockedResponse, NetworkError(error: nil,
                                                     response: mockedResponse,
                                                     serverErrorPayload: nil))
        }

        return MockURLSessionDataTask()
    }
    
    func addStub(fullURL: String, response: String) {
        
        stubbedResponses[fullURL] = response
    }
    
    func removeStubs() {
        
        stubbedResponses = [:]
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
