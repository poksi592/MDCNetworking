//
//  PactNetworkClient.swift
//  MDCNetworking
//
//  Created by Bartomiej Nowak on 23/02/2018.
//  Copyright © 2018 Despotovic, Mladen. All rights reserved.
//

import Foundation

/**
 * Adds stubbing capabilities to an object based on Pact specification.
 */
public protocol InteractionStubbable {
    func addStubbedInteraction(
        providerState: String,
        description: String,
        method: HTTPMethod,
        path: String,
        parameters: [String: String]?,
        responseStatus: Int,
        responseBody: Any?
    ) throws
}

/**
 * Network client with the possibility of stubbing selected request responses using Pact interactions. Gathers all
 * interactions into a Pact model ready for serialization and sending to a contract broker or repository.
 *
 * [Pact specification can be found here](https://github.com/pact-foundation/pact-specification/tree/version-2).
 */
open class PactNetworkClient: NetworkClientInterface, InteractionStubbable {
    
    open let configuration: Configuration
    open let sessionProvider: PactSessionProvider
    
    public init(configuration: Configuration, sessionProvider: PactSessionProvider) {
        self.configuration = configuration
        self.sessionProvider = sessionProvider
    }
    
    /**
     * Creates a `HTTPSession` based on provided `Configuration` which response will be stubbed if matching
     * request/response pair can be found in the `PactSessionProvider`.
     *
     * - parameter path: String describing the path. Added to the schema/host provided by `Configuration` model.
     * - parameter method: HTTP method.
     * - parameter parameters: Query items to be serialized into the request URL.
     * - parameter body: Contents of the body sent with the request.
     * - parameter additionalHeaderFields: Additional header fields to be included with the request. Will override header fields set from `Configuration` model.
     * - parameter session: Overrides the `URLSession` used by the session.
     * - parameter completion: Callback executed when receiving a response.
     */
    open func session(
        path: String,
        method: HTTPMethod = .get,
        parameters: [String : String]? = nil,
        body: Data? = nil,
        additionalHeaderFields: [String: String]? = nil,
        session: URLSession? = nil,
        completion: @escaping ResponseCallback
    ) throws -> HTTPSession {
        
        let session = HTTPSession(
            path: path,
            method: method,
            parameters: parameters,
            body: body,
            configuration: configuration,
            session: session,
            completion: completion
        )
        
        session.request.additionalHeaderFields = additionalHeaderFields
        session.sessionProvider = sessionProvider
        
        return session
    }
    
    /**
     * Stubs the response for selected request.
     *
     * - parameter providerState: String describing the provider's context required for the interaction.
     * [See pact specification](https://docs.pact.io/documentation/provider_states.html).
     * - parameter description: Short description of the interaction, e.g. _get all highlights for current user_
     * - parameter method: HTTP method name.
     * - parameter path: Request URL path.
     * - parameter parameters: Request parameters.
     * - parameter responseStatus: HTTP response status.
     * - parameter responseBody: HTTP response body.
     */
    open func addStubbedInteraction(
        providerState: String,
        description: String,
        method: HTTPMethod,
        path: String,
        parameters: [String: String]? = nil,
        responseStatus: Int,
        responseBody: Any? = nil
    ) throws {
        
        try sessionProvider.generateInteraction(
            providerState: providerState,
            description: description,
            method: method,
            path: path,
            parameters: parameters,
            responseStatus: responseStatus,
            responseBody: responseBody
        )
    }
}
