//
//  PactStubProvider.swift
//  MDCNetworking
//
//  Created by Bartomiej Nowak on 22/01/2018.
//  Copyright © 2018 Despotovic, Mladen. All rights reserved.
//

import Foundation

/**
 * Concrete `URLSessionProvider` implementation that generates a Pact based on provided details and allows for adding
 * interactions (request, response pairs). `URLSessionProvider` interface provides `URLSession`s with stubbed responses
 * for requests matching the ones specified in provided interactions.
 *
 * More information about Pact specification can be found here: https://docs.pact.io/documentation/how_does_pact_work.html
 */
open class PactSessionProvider {
    
    public struct UrlGenerationError: Error {}
    public struct UrlResponseGenerationError: Error {}
    
    private let schema: String
    private let host: String
    private let requestHeaders: [String: String]
    private let responseHeaders: [String: String]
    
    public private (set) var pact: Pact!
    
    public init(
        schema: String,
        host: String,
        requestHeaders: [String: String] = ["Content-Type": "application/json; charset=UTF-8"],
        responseHeaders: [String: String] = ["Content-Type": "application/json; charset=UTF-8"],
        pactVersion: String,
        providerName: String,
        consumerName: String
    ) {
        self.host = host
        self.schema = schema
        self.requestHeaders = requestHeaders
        self.responseHeaders = responseHeaders
        
        pact = Pact(
            providerName: providerName,
            consumerName: consumerName,
            interactions: [],
            version: pactVersion
        )
    }
    
    /**
     * Attempts to generate a `Pact.Interaction` and appends it to list of known interactions.
     */
    open func generateInteraction(
        providerState: String,
        description: String,
        method: HTTPMethod,
        path: String,
        parameters: [String: String]? = nil,
        responseStatus: Int,
        responseBody: [String: Any]? = nil
    ) throws {
        
        guard let url = URL(schema: schema, host: host, path: path, parameters: parameters) else {
            throw UrlGenerationError()
        }
        
        guard
            let urlResponse = HTTPURLResponse(
                url: url,
                statusCode: responseStatus,
                httpVersion: nil,
                headerFields: responseHeaders
            )
        else {
            throw UrlResponseGenerationError()
        }
        
        var urlRequest = URLRequest(url: url)
        
        requestHeaders.forEach { urlRequest.addValue($0.value, forHTTPHeaderField: $0.key) }
        
        pact.append(
            Pact.Interaction(
                providerState: providerState,
                description: description,
                request: Pact.Request(method: method, urlRequest: urlRequest),
                response: Pact.Response(urlResponse: urlResponse, body: responseBody)
            )
        )
    }
}

extension PactSessionProvider: URLSessionProvider {
    
    public func session(for urlRequest: URLRequest) -> URLSession? {
        let matchingInteractions = pact.interactions.filter { $0.matches(request: urlRequest, matchingOptions: [.url]) }
        
        guard
            let interaction = matchingInteractions.first,
            let responseData = try? JSONSerialization.data(
                withJSONObject: interaction.response.body as Any,
                options: .prettyPrinted
            )
        else {
            return nil
        }
        
        return PactStubbedURLSession(response: responseData, urlResponse: interaction.response.urlResponse)
    }
}
