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
    
    private let baseURL: URL
    private let requestHeaders: [String: String]
    private let responseHeaders: [String: String]
    
    public private (set) var pact: Pact!
    
    public init(
        baseURL: URL,
        requestHeaders: [String: String] = ["Content-Type": "application/json; charset=UTF-8"],
        responseHeaders: [String: String] = ["Content-Type": "application/json; charset=UTF-8"],
        pactVersion: String,
        providerName: String,
        consumerName: String
    ) {
        self.baseURL = baseURL
        self.requestHeaders = requestHeaders
        self.responseHeaders = responseHeaders
        self.pact = Pact(providerName: providerName, consumerName: consumerName, interactions: [], version: pactVersion)
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
        responseBody: Any? = nil
    ) throws {
        var additionalPath = path
        
        if additionalPath.first != "/" {
            additionalPath.insert("/", at: additionalPath.startIndex)
        }
        
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else {
            throw InvalidBaseUrl()
        }
        
        components.path = baseURL.path + additionalPath
        
        guard let url = components.url else {
            throw UrlConstructionError()
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
