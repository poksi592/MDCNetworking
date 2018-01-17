//
//  ErrorHandling.swift
//  MDCNetworking
//
//  Created by Despotovic, Mladen on 15/12/2016.
//  Copyright © 2016 Despotovic, Mladen. All rights reserved.
//

import Foundation

public enum NetworkError: Error {

    case NotRecognized
    case SerialisationFailed
    case TaskCancelled
    case BadRequest400(error: Error?, response: HTTPURLResponse?, serverErrorPayload: [String:Any]?)
    case Unauthorized401(error: Error?, response: HTTPURLResponse?, serverErrorPayload: [String:Any]?)
    case Forbidden403(error: Error?, response: HTTPURLResponse?, serverErrorPayload: [String:Any]?)
    case NotFound404(error: Error?, response: HTTPURLResponse?, serverErrorPayload: [String:Any]?)
    case other400(error: Error?, response: HTTPURLResponse?, serverErrorPayload: [String:Any]?)
    case ServerError500(error: Error?, response: HTTPURLResponse?, serverErrorPayload: [String:Any]?)
    
    init?(error: Error?, response: HTTPURLResponse?, serverErrorPayload: [String:Any]?) {
        
        let responseCode: Int
        if let response = response {
            responseCode = response.statusCode
        } else {
            responseCode = 0
            self = .NotRecognized
        }
        
        switch responseCode {
            case 200..<300:
                return nil
            case 400:
                self = .BadRequest400(error: error, response: response, serverErrorPayload: serverErrorPayload)
            case 401:
                self = .Unauthorized401(error: error, response: response, serverErrorPayload: serverErrorPayload)
            case 403:
                self = .Forbidden403(error: error, response: response, serverErrorPayload: serverErrorPayload)
            case 404:
                self = .NotFound404(error: error, response: response, serverErrorPayload: serverErrorPayload)
            case 405..<500:
                self = .other400(error: error, response: response, serverErrorPayload: serverErrorPayload)
            case 500..<600:
                self = .ServerError500(error: error, response: response, serverErrorPayload: serverErrorPayload)
            default:
                self = .NotRecognized
        }
    }
}


