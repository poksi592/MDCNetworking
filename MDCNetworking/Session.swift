//
//  Session.swift
//  MDCNetworking
//
//  Created by Despotovic, Mladen on 19/12/2016.
//  Copyright © 2016 Despotovic, Mladen. All rights reserved.
//

import Foundation

public typealias RequestCompletion = (Any?, HTTPURLResponse?, NetworkError?, _ cancelled: Bool) -> Void
public typealias DataTaskClosure = (Data?, URLResponse?, Error?) -> Void

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

public protocol URLSessionProvider {
    func session(for urlRequest:URLRequest) -> URLSession?
}

public protocol CancelableSession: URLSessionDelegate {
    
    var completion: RequestCompletion { get set }
    var configuration: NetworkConfiguration { get set }
    var requestURLPath: String { get set }
    var httpMethod: HTTPMethod { get set }
    var additionalHeaders: [String: String] { get set }
    var parameters: [String: String]? { get set }
    var httpBody: Data? { get set }
    weak var session: URLSession? { get set }
    var sessionProvider: URLSessionProvider? { get set }
    
    init(
        requestURLPath: String,
        httpMethod: HTTPMethod,
        parameters: [String: String]?,
        httpBody: Data?,
        configuration: NetworkConfiguration,
        session: URLSession?,
        completion: @escaping RequestCompletion
    )
    
    func start() throws
    func cancel()
    func dataTaskClosure() -> DataTaskClosure
}

extension CancelableSession {
    
    public func start() throws {
        var request = try configuration.request(path: requestURLPath, parameters: parameters)

        request.httpMethod = httpMethod.rawValue
        request.httpBody = httpBody
        
        if session == nil {
            session = URLSession(configuration: configuration.sessionConfiguration)
        }
        
        let task = session?.dataTask(with: request, completionHandler: dataTaskClosure())
        
        task?.resume()
    }
    
    public func cancel() {
        
        if let session = session {
            session.invalidateAndCancel()
            completion(nil, HTTPURLResponse(), .taskCancelled, false)
        }
    }
}

public class JSONSession: NSObject, CancelableSession {

    public var completion: RequestCompletion
    public var configuration: NetworkConfiguration
    public var requestURLPath: String
    public var httpMethod: HTTPMethod
    public var additionalHeaders: [String: String] = [:]
    public var parameters: [String: String]?
    public var httpBody: Data?
    public var session: URLSession?
    public var sessionProvider: URLSessionProvider? = nil
    
    @available(*, unavailable)
    override init() {
        fatalError()
    }
    
    public required init(
        requestURLPath: String,
        httpMethod: HTTPMethod = .get,
        parameters: [String: String]? = nil,
        httpBody: Data? = nil,
        configuration: NetworkConfiguration,
        session: URLSession? = nil,
        completion: @escaping RequestCompletion
    ) {
        self.requestURLPath = requestURLPath
        self.httpMethod = httpMethod
        self.completion = completion
        self.configuration = configuration
        self.session = session
        self.httpBody = httpBody
        
        if let parameters = parameters {
            self.parameters = parameters
        }
    }
    
    public func dataTaskClosure() -> (Data?, URLResponse?, Error?) -> Void {
        
        return { (data, response, error) in
            
            var responseObject: [String: Any]? = nil
            var networkingError: NetworkError? = nil
            if let data = data {
                
                do {
                    
                    responseObject = try JSONSerialization.jsonObject(with: data,
                                                                      options: .mutableContainers) as? [String: Any]
                }
                catch {
                    
                    networkingError = .serializationFailed
                }
            }
            
            if let error = error {

                if let data = data {
                    
                    responseObject = try? JSONSerialization.jsonObject(with: data,
                                                                       options: .mutableContainers) as! [String: Any]
                }
                networkingError = NetworkError(error: error,
                                               response: response as? HTTPURLResponse,
                                               serverErrorPayload: responseObject)
            }
            self.completion(responseObject, response as? HTTPURLResponse, networkingError, false)
        }
    }

    public func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard let certificatesPathsForResource = configuration.certificatesPathsForResource else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        let serverTrust = challenge.protectionSpace.serverTrust
        let certificate = SecTrustGetCertificateAtIndex(serverTrust!, 0)
        
        // Set SSL policies for domain name check
        let policies = NSMutableArray();
        policies.add(SecPolicyCreateSSL(true, (challenge.protectionSpace.host as CFString)))
        SecTrustSetPolicies(serverTrust!, policies);
        
        // Evaluate server certificate
        var result: SecTrustResultType = .invalid
        SecTrustEvaluate(serverTrust!, &result)
        let isServerTrusted:Bool = (result == .unspecified || result == .proceed)
        guard isServerTrusted == true else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        // Get local and remote cert data
        let remoteCertificateData:NSData = SecCertificateCopyData(certificate!)
        var credential: URLCredential? = nil
        
        for certificatePathForResource in certificatesPathsForResource {
            
            guard let pathToCert = Bundle.main.path(forResource: certificatePathForResource, ofType: "cer") else {
                completionHandler(.cancelAuthenticationChallenge, nil)
                return
            }
            let urlToCert = URL(fileURLWithPath: pathToCert)
            guard let localCertificate = try? Data(contentsOf: urlToCert) else {
                completionHandler(.cancelAuthenticationChallenge, nil)
                return
            }
            if (remoteCertificateData.isEqual(to: localCertificate)) {
                credential = URLCredential(trust: serverTrust!)
            }
        }
        
        guard let pinnedCredential = credential else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        completionHandler(.useCredential, pinnedCredential)
    }
}

