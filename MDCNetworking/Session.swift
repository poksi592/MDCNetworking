//
//  Session.swift
//  MDCNetworking
//
//  Created by Despotovic, Mladen on 19/12/2016.
//  Copyright © 2016 Despotovic, Mladen. All rights reserved.
//

import Foundation

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

public struct EmptyResponseBody: Decodable {}

public protocol JSONSessionInterface: URLSessionDelegate {
    
    associatedtype ResponseModelType: Decodable
    
    typealias ResponseCallback = (HTTPURLResponse?, ResponseModelType?, NetworkError?, _ cancelled: Bool) -> Void
    
    var configuration: NetworkConfiguration { get set }
    var request: Request { get set }
    weak var session: URLSession? { get set }
    var sessionProvider: URLSessionProvider? { get set }
    var completion: ResponseCallback { get set }
    
    func start() throws
    func cancel()
    func dataTaskClosure() -> DataTaskCallback
}

extension JSONSessionInterface {
    
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
        
        session?
            .dataTask(with: urlRequest, completionHandler: dataTaskClosure())
            .resume()
    }
    
    public func cancel() {
        if let session = session {
            session.invalidateAndCancel()
            completion(HTTPURLResponse(), nil, .taskCancelled, false)
        }
    }
}

public struct Request {
    
    let urlPath: String
    let method: HTTPMethod
    let additionalHeaders: [String: String]
    let parameters: [String: String]?
    let body: Data?
    
    public init(
        urlPath: String,
        method: HTTPMethod = .get,
        additionalHeaders: [String: String] = [:],
        parameters: [String: String]? = nil,
        body: Data? = nil
    ) {
        self.urlPath = urlPath
        self.method = method
        self.additionalHeaders = additionalHeaders
        self.parameters = parameters
        self.body = body
    }
}

public final class JSONSession: GenericJSONSession<EmptyResponseBody> {}

public class GenericJSONSession<ResponseModel: Decodable>: NSObject, JSONSessionInterface {
    
    public typealias ResponseModelType = ResponseModel
    
    public var configuration: NetworkConfiguration
    public var request: Request
    public var session: URLSession?
    public var sessionProvider: URLSessionProvider? = nil
    public var completion: ResponseCallback
    
    public required init(
        urlPath: String,
        method: HTTPMethod = .get,
        parameters: [String: String]? = nil,
        body: Data? = nil,
        configuration: NetworkConfiguration,
        session: URLSession? = nil,
        completion: @escaping ResponseCallback
    ) {
        self.request = Request(urlPath: urlPath, method: method, parameters: parameters, body: body)
        self.session = session
        self.configuration = configuration
        self.completion = completion
    }
    
    public func dataTaskClosure() -> (Data?, URLResponse?, Error?) -> Void {
        return { data, response, error in
            var networkError: NetworkError? = nil
            var responseModel: ResponseModel? = nil
            
            if let error = error {
                networkError = NetworkError(error: error, response: response as? HTTPURLResponse, payload: data)
            }
            
            if let data = data {
                responseModel = ModelDecoder<ResponseModel>().decode(jsonData: data, dateDecodingStrategy: .iso8601)
            }
            
            self.completion(response as? HTTPURLResponse, responseModel, networkError, false)
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

