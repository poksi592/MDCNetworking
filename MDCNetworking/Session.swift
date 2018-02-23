//
//  Session.swift
//  MDCNetworking
//
//  Created by Despotovic, Mladen on 19/12/2016.
//  Copyright © 2016 Despotovic, Mladen. All rights reserved.
//

import Foundation

public typealias ResponseCallback = (HTTPURLResponse?, Any?, NetworkError?, _ cancelled: Bool) -> Void
public typealias DataTaskCallback = (Data?, URLResponse?, Error?) -> Void

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

public protocol URLSessionProvider {
    func session(for urlRequest: URLRequest) -> URLSession?
}

public protocol HTTPSessionInterface: URLSessionDelegate {
    
    var configuration: Configuration { get set }
    var request: Request { get set }
    weak var session: URLSession? { get set }
    var sessionProvider: URLSessionProvider? { get set }
    var completion: ResponseCallback { get set }
    
    func start() throws
    func cancel()
    func dataTaskCallback() -> DataTaskCallback
}

extension HTTPSessionInterface {
    
    public func start() throws {
        var urlRequest = try configuration.request(path: request.urlPath, parameters: request.parameters)

        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = request.body
        
        if session == nil {
            session = sessionProvider?.session(for: urlRequest) ?? URLSession(
                configuration: configuration.sessionConfiguration,
                delegate: self,
                delegateQueue: nil
            )
        }
        
        session?.dataTask(with: urlRequest, completionHandler: dataTaskCallback()).resume()
    }
    
    public func cancel() {
        if let session = session {
            session.invalidateAndCancel()
            completion(HTTPURLResponse(), nil, .taskCancelled, false)
        }
    }
}

public struct Request {
    public var urlPath: String
    public var method: HTTPMethod
    public var additionalHeaders: [String: String]
    public var parameters: [String: String]?
    public var body: Data?
}

public class HTTPSession: NSObject, HTTPSessionInterface {
    
    public var completion: ResponseCallback
    public var configuration: Configuration
    public var request: Request
    public var session: URLSession?
    public var sessionProvider: URLSessionProvider? = nil
    
    public required init(
        urlPath: String,
        method: HTTPMethod = .get,
        parameters: [String: String]? = nil,
        body: Data? = nil,
        configuration: Configuration,
        session: URLSession? = nil,
        completion: @escaping ResponseCallback
    ) {
        self.request = Request(
            urlPath: urlPath,
            method: method,
            additionalHeaders: [:],
            parameters: parameters,
            body: body
        )
        self.configuration = configuration
        self.session = session
        self.completion = completion
    }
    
    public func dataTaskCallback() -> (Data?, URLResponse?, Error?) -> Void {
        return { data, response, error in
            
            var networkError: NetworkError? = nil
            var responseBody: Any? = nil
            
            if let error = error {
                networkError = NetworkError(error: error, response: response as? HTTPURLResponse, payload: data)
            }
            
            if let data = data {
                do {
                    responseBody = try JSONSerialization.jsonObject(with: data)
                } catch {
                    networkError = .serializationFailed
                }
            }
        
            self.completion(response as? HTTPURLResponse, responseBody, networkError, false)
        }
    }

    public func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        switch challenge.protectionSpace.authenticationMethod {
            case NSURLAuthenticationMethodServerTrust
            where configuration.sslPinningMode == .certificate && !(configuration.pinnedCertificates?.isEmpty ?? true):
                
                verifyPinnedCertificates(for: challenge, completionHandler: completionHandler)
            default:
                completionHandler(.performDefaultHandling, nil)
        }
    }
    
    /**
     Performs SSL domain and leaf certificate validation.
     */
    private func verifyPinnedCertificates(
        for challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard let pinnedCertificates = configuration.pinnedCertificates else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        
        SecTrustSetPolicies(
            challenge.protectionSpace.serverTrust!,
            [SecPolicyCreateSSL(true, (challenge.protectionSpace.host as CFString))] as NSArray
        )
        
        var result: SecTrustResultType = .invalid
        SecTrustEvaluate(challenge.protectionSpace.serverTrust!, &result)
        
        guard result == .unspecified || result == .proceed else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        let certificate = SecTrustGetCertificateAtIndex(challenge.protectionSpace.serverTrust!, 0)
        let remoteCertificate = SecCertificateCopyData(certificate!) as NSData as Data
        
        if pinnedCertificates.contains(remoteCertificate) {
            completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}

