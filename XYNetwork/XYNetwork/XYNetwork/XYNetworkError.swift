//
//  XYNetworkError.swift
//  HTTPRequest
//
//  Created by 白野 on 2019/8/13.
//  Copyright © 2019 白野. All rights reserved.
//
//  错误

import Foundation

enum XYNetworkError: Error {

    enum RequestSerializationFailureReason {
        case jsonSerializationFailed(error: Error)
    }

    enum ResponseSerializationFailureReason {
        case jsonSerializationFailed(error: Error)
    }

    
    case sessionUninitialized
    case dataTaskUninitialized
    case requesterUninitialized
    case responserUninitialized
    case invalidURL(URLString: String)
    case invalidRequest
    case requestSerializationFailed(reason: RequestSerializationFailureReason)
    case responseSerializationFailed(reason: ResponseSerializationFailureReason)
}

extension XYNetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .sessionUninitialized:
            return "session uninitialized"
        case .dataTaskUninitialized:
            return "data task uninitialized"
        case .requesterUninitialized:
            return "requester uninitialized"
        case .responserUninitialized:
            return "responser uninitialized"
        case .invalidURL(let URLString):
            return "URLString is invalid: \(URLString)"
        case .invalidRequest:
            return "request is invalid"
        case .requestSerializationFailed(let reason):
            return reason.localizedDescription
        case .responseSerializationFailed(let reason):
            return reason.localizedDescription
        }
    }
}

extension XYNetworkError.RequestSerializationFailureReason {
    var localizedDescription: String {
        switch self {
        case .jsonSerializationFailed(let error):
            return "request JSON could not be serialized because of error:\n\(error.localizedDescription)"
        }
    }
}

extension XYNetworkError.ResponseSerializationFailureReason {
    var localizedDescription: String {
        switch self {
        case .jsonSerializationFailed(let error):
            return "response JSON could not be serialized because of error:\n\(error.localizedDescription)"
        }
    }
}
