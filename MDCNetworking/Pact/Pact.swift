//
//  Pact.swift
//  MDCNetworking
//
//  Created by Bartomiej Nowak on 17/01/2018.
//  Copyright © 2018 Despotovic, Mladen. All rights reserved.
//

import Foundation

public struct URLRequestComparisonOption: OptionSet {
    
    public static let headers = URLRequestComparisonOption(rawValue: 1 << 0)
    public static let url = URLRequestComparisonOption(rawValue: 1 << 1)
    
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

// MARK: - Pact

public struct Pact: Encodable {
    
    // MARK: - Types
    
    public struct Request: Encodable {
        
        public struct PathEncodingError: Error {}
        
        enum CodingKeys: String, CodingKey {
            case method
            case path
            case query
        }
        
        public let method: HTTPMethod
        public let urlRequest: URLRequest
        
        public init(method: HTTPMethod, urlRequest: URLRequest) {
            self.method = method
            self.urlRequest = urlRequest
        }
        
        public func encode(to encoder: Encoder) throws {
            guard let path = urlRequest.url?.path else {
                throw PathEncodingError()
            }
            
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encode(method.rawValue, forKey: .method)
            try container.encode(path, forKey: .path)
            try container.encodeIfPresent(urlRequest.url?.query, forKey: .query)
        }
    }
    
    public struct Response: Encodable {
        
        public let urlResponse: HTTPURLResponse
        public let body: Any?
        
        enum CodingKeys: String, CodingKey {
            case status
            case headers
            case body
        }
        
        public init(urlResponse: HTTPURLResponse, body: Any?) {
            self.urlResponse = urlResponse
            self.body = body
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encode(urlResponse.statusCode, forKey: .status)
            try container.encodeIfPresent(urlResponse.allHeaderFields as? [String: String], forKey: .headers)
            
            if let body = body as? [String : Any] {
                var bodyContainer = container.nestedContainer(keyedBy: DynamicKey.self, forKey: .body)
                
                for pair in body {
                    try bodyContainer.encode(jsonValue: pair.value, forKey: DynamicKey(stringValue: pair.key)!)
                }
            } else if let body = body as? [Any] {
                var bodyContainer = container.nestedUnkeyedContainer(forKey: .body)
                
                try bodyContainer.encode(jsonValue: body)
            }
        }
    }
    
    public struct Interaction: Encodable {
        
        public let providerState: String
        public let description: String
        public let request: Request
        public let response: Response
        
        enum CodingKeys: String, CodingKey {
            case providerState = "provider_state"
            case description
            case request
            case response
        }
        
        public init(providerState: String, description: String, request: Request, response: Response) {
            self.providerState = providerState
            self.description = description
            self.request = request
            self.response = response
        }
        
        public func matches(request: URLRequest, matchingOptions: URLRequestComparisonOption) -> Bool {
            switch matchingOptions {
                case [.headers]:
                    guard
                        let comparisonHeaders = request.allHTTPHeaderFields,
                        let requestHeaders = self.request.urlRequest.allHTTPHeaderFields
                    else {
                        return false
                    }
                    
                    return comparisonHeaders == requestHeaders
                case [.url]:
                    return request.url == self.request.urlRequest.url
                case [.headers, .url]:
                    guard
                        let comparisonHeaders = request.allHTTPHeaderFields,
                        let requestHeaders = self.request.urlRequest.allHTTPHeaderFields
                    else {
                        return false
                    }
                    
                    return (request.url == self.request.urlRequest.url) && (comparisonHeaders == requestHeaders)
                default:
                    return false
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case provider
        case consumer
        case metadata
        case interactions
    }
    
    enum ProviderCodingKeys: String, CodingKey {
        case name
    }
    
    enum ConsumerCodingKeys: String, CodingKey {
        case name
    }
    
    enum MetadataCodingKeys: String, CodingKey {
        case pactSpecification
    }
    
    enum PactSpecificationCodingKeys: String, CodingKey {
        case version
    }
    
    // MARK: - Definition
    
    public let providerName: String
    public let consumerName: String
    public let version: String
    public private (set) var interactions: [Interaction]
    
    /**
     * Initializes a pact with specified provider and consumer names, interactions and application version. Note that
     * it's the client application version, versioning of the pact itself is handled by the broker.
     */
    public init(providerName: String, consumerName: String, interactions: [Interaction], version: String) {
        self.providerName = providerName
        self.consumerName = consumerName
        self.interactions = interactions
        self.version = version
    }
    
    mutating func append(_ interaction: Interaction) {
        interactions.append(interaction)
    }
    
    mutating func append(_ interactions: [Interaction]) {
        self.interactions.append(contentsOf: interactions)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        var providerContainer = container.nestedContainer(keyedBy: ProviderCodingKeys.self, forKey: .provider)
        try providerContainer.encode(providerName, forKey: .name)
        
        var consumerContainer = container.nestedContainer(keyedBy: ConsumerCodingKeys.self, forKey: .consumer)
        try consumerContainer.encode(consumerName, forKey: .name)
        
        var metadataContainer = container.nestedContainer(keyedBy: MetadataCodingKeys.self, forKey: .metadata)
        var specificationContainer = metadataContainer.nestedContainer(keyedBy: PactSpecificationCodingKeys.self, forKey: .pactSpecification)
        try specificationContainer.encode(version, forKey: .version)
        
        try container.encode(interactions, forKey: .interactions)
    }
}

// MARK: - Interaction Factory

public struct PactInteractionFactory {
    
    let host: String
    let schema: String
    let requestHeaders: [String: String]
    let responseHeaders: [String: String]
    
    public init(
        host: String,
        schema: String,
        requestHeaders: [String: String]? = nil,
        responseHeaders: [String: String]? = nil
    ) {
        self.host = host
        self.schema = schema
        self.requestHeaders = requestHeaders ?? ["Content-Type": "application/json; charset=UTF-8"]
        self.responseHeaders = responseHeaders ?? ["Content-Type": "application/json; charset=UTF-8"]
    }
    
    public func createInteraction(
        providerState: String,
        description: String,
        method: HTTPMethod,
        path: String,
        parameters: [String: String]? = nil,
        responseStatusCode: Int,
        responseBody: Any? = nil
    ) -> Pact.Interaction? {
        
        guard
            let url = URL(schema: schema, host: host, path: path, parameters: parameters),
            let urlResponse = HTTPURLResponse(
                url: url,
                statusCode: responseStatusCode,
                httpVersion: nil,
                headerFields: responseHeaders
            )
        else {
            return nil
        }
        
        var urlRequest = URLRequest(url: url)
        
        requestHeaders.forEach { urlRequest.addValue($0.value, forHTTPHeaderField: $0.key) }
        
        let pactInteraction = Pact.Interaction(
            providerState: providerState,
            description: description,
            request: Pact.Request(method: method, urlRequest: urlRequest),
            response: Pact.Response(urlResponse: urlResponse, body: responseBody)
        )
        
        return pactInteraction
    }
}
