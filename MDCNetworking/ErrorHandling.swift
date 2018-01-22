//
//  ErrorHandling.swift
//  MDCNetworking
//
//  Created by Despotovic, Mladen on 15/12/2016.
//  Copyright © 2016 Despotovic, Mladen. All rights reserved.
//

import Foundation

public enum NetworkError: Error {

    case serializationFailed
    case taskCancelled
    case badRequest400(error: Error?, response: HTTPURLResponse?, serverErrorPayload: [String: Any]?)
    case unauthorized401(error: Error?, response: HTTPURLResponse?, serverErrorPayload: [String: Any]?)
    case forbidden403(error: Error?, response: HTTPURLResponse?, serverErrorPayload: [String: Any]?)
    case notFound404(error: Error?, response: HTTPURLResponse?, serverErrorPayload: [String: Any]?)
    case other400(error: Error?, response: HTTPURLResponse?, serverErrorPayload: [String: Any]?)
    case serverError500(error: Error?, response: HTTPURLResponse?, serverErrorPayload: [String: Any]?)
    case other
    
    init?(error: Error?, response: HTTPURLResponse?, serverErrorPayload: [String: Any]?) {
        
        let responseCode: Int
        if let response = response {
            responseCode = response.statusCode
        } else {
            responseCode = 0
            self = .other
        }
        
        switch responseCode {
            case 200..<300:
                return nil
            case 400:
                self = .badRequest400(error: error, response: response, serverErrorPayload: serverErrorPayload)
            case 401:
                self = .unauthorized401(error: error, response: response, serverErrorPayload: serverErrorPayload)
            case 403:
                self = .forbidden403(error: error, response: response, serverErrorPayload: serverErrorPayload)
            case 404:
                self = .notFound404(error: error, response: response, serverErrorPayload: serverErrorPayload)
            case 405..<500:
                self = .other400(error: error, response: response, serverErrorPayload: serverErrorPayload)
            case 500..<600:
                self = .serverError500(error: error, response: response, serverErrorPayload: serverErrorPayload)
            default:
                self = .other
        }
    }
}


