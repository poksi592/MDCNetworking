//
//  ErrorHandling.swift
//  MDCNetworking
//
//  Created by Despotovic, Mladen on 15/12/2016.
//  Copyright © 2016 Despotovic, Mladen. All rights reserved.
//

import Foundation

enum NetworkError: Error {

    case NotRecognized
    case NoError200
    case NoError201
    case NoError204
    case BadRequest400(error: Error?, response: HTTPURLResponse, serverErrorPayload: [String:String]?)
    case Unauthorized401(error: Error?, response: HTTPURLResponse, serverErrorPayload: [String:String]?)
    case Forbidden403(error: Error?, response: HTTPURLResponse, serverErrorPayload: [String:String]?)
    case NotFound404(error: Error?, response: HTTPURLResponse, serverErrorPayload: [String:String]?)
    case ServerError500(error: Error?, response: HTTPURLResponse, serverErrorPayload: [String:String]?)
    
    init(error: Error?, response: HTTPURLResponse, serverErrorPayload: [String:String]?) {
        
        switch response.statusCode {
          
        case 200:
            self = .NoError200
        case 201:
            self = .NoError201
        case 204:
            self = .NoError204
        case 400:
            self = .BadRequest400(error: error, response: response, serverErrorPayload: serverErrorPayload)
        case 401:
            self = .Unauthorized401(error: error, response: response, serverErrorPayload: serverErrorPayload)
        case 403:
            self = .Forbidden403(error: error, response: response, serverErrorPayload: serverErrorPayload)
        case 404:
            self = .NotFound404(error: error, response: response, serverErrorPayload: serverErrorPayload)
        case 500..<600:
            self = .ServerError500(error: error, response: response, serverErrorPayload: serverErrorPayload)
        default:
            self = .NotRecognized
        }
    }
}


