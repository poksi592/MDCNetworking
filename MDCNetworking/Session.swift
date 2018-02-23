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
        var urlRequest = try configuration.request(path: request.path, parameters: request.parameters)

        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = request.body
        
        if session == nil {
            session = sessionProvider?.session(for: urlRequest) ?? URLSession(
                configuration: configuration.sessionConfiguration,
                delegate: self,
                delegateQueue: nil
            )
        }
        
        request.additionalHeaderFields?.forEach { urlRequest.addValue($1, forHTTPHeaderField: $0) }
        
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
    public var path: String
    public var method: HTTPMethod
    public var additionalHeaderFields: [String: String]?
    public var parameters: [String: String]?
    public var body: Data?
}

public class HTTPSession: NSObject {
    
    public var completion: ResponseCallback
    public var configuration: Configuration
    public var request: Request
    public var session: URLSession?
    public var sessionProvider: URLSessionProvider? = nil
    
    public required init(
        path: String,
        method: HTTPMethod = .get,
        parameters: [String: String]? = nil,
        body: Data? = nil,
        configuration: Configuration,
        additionalHeaderFields: [String: String]? = nil,
        session: URLSession? = nil,
        completion: @escaping ResponseCallback
    ) {
        self.request = Request(
            path: path,
            method: method,
            additionalHeaderFields: additionalHeaderFields,
            parameters: parameters,
            body: body
        )
        self.configuration = configuration
        self.session = session
        self.completion = completion
    }
}

extension HTTPSession: HTTPSessionInterface {
    
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
        
        /*
         For reference: https://github.com/iSECPartners/ssl-conservatory
         */
        
        switch challenge.protectionSpace.authenticationMethod {
            case NSURLAuthenticationMethodServerTrust:
                let trust = challenge.protectionSpace.serverTrust!
                let hostname = challenge.protectionSpace.host as CFString
                
                guard isCertificateChainValid(with: trust) else {
                    completionHandler(.cancelAuthenticationChallenge, nil)
                    return
                }
                
                if configuration.sslPinningMode == .certificate {
                    verifyWithPinnedCertificates(trust, hostname: hostname, completionHandler: completionHandler)
                } else {
                    completionHandler(.useCredential, URLCredential(trust: trust))
                }
            default:
                completionHandler(.performDefaultHandling, nil)
        }
    }
    
    /**
     Validates the certificate chain with the device's trust store.
     */
    private func isCertificateChainValid(with trust: SecTrust) -> Bool {
        var result: SecTrustResultType = .invalid
        SecTrustEvaluate(trust, &result)
        return result == .unspecified || result == .proceed
    }
    
    /**
     Performs matching with pinned certificates.
     */
    private func verifyWithPinnedCertificates(
        _ trust: SecTrust,
        hostname: CFString,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard let pinnedCertificates = configuration.pinnedCertificates else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        SecTrustSetPolicies(trust, [SecPolicyCreateSSL(true, hostname)] as NSArray)
        
        if isLeafCertificateMatchingAnyPinnedCertificates(from: trust, with: pinnedCertificates) {
            completionHandler(.useCredential, URLCredential(trust: trust))
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
    
    /**
     Attempts to match the leaf certificate extracted from trust object to any of provided pinned certificates.
     */
    private func isLeafCertificateMatchingAnyPinnedCertificates(
        from serverTrust: SecTrust,
        with pinnedCertificates: [Data]
    ) -> Bool {
        let leafCertificate = SecCertificateCopyData(SecTrustGetCertificateAtIndex(serverTrust, 0)!) as NSData as Data
        return pinnedCertificates.contains(leafCertificate)
    }
}

