//
//  XYNetworkRequestSerializer.swift
//  HTTPRequest
//
//  Created by 白野 on 2019/8/12.
//  Copyright © 2019 白野. All rights reserved.
//
//  请求器，用于解析参数并生成请求

import UIKit

class XYNetworkRequester: NSObject {

    func request(baseURLString: String, URLString: String, httpMethod: String?, allHTTPHeaderFields: [String : String]?) throws -> URLRequest {
        guard let url = URL(string: URLString, relativeTo: URL(string: baseURLString)) else {
            throw XYNetworkError.invalidURL(URLString: URLString)
        }
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.allHTTPHeaderFields = allHTTPHeaderFields
        return request
    }

    func URLParameters(request: inout URLRequest, parameters: Any?) -> URLRequest {
        if let parameters = parameters, let url = request.url {
            request.url = self.URLForQueryItems(url: url, parameters: parameters)
        }
        return request
    }
    
    func stringParameters(request: inout URLRequest, parameters: Any?) -> URLRequest {
        if let parameters = parameters {
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            
            let queryString = self.queryString(parameters: parameters)
            let httpBody = queryString.data(using: String.Encoding.utf8)
            request.httpBody = httpBody
        }
        return request
    }
    
    func JSONParameters(request: inout URLRequest, parameters: Any?) throws -> URLRequest {
        if let parameters = parameters, JSONSerialization.isValidJSONObject(parameters) {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            do {
                let httpBody = try JSONSerialization.data(withJSONObject: parameters)
                request.httpBody = httpBody
            } catch {
                throw XYNetworkError.requestSerializationFailed(reason: .jsonSerializationFailed(error: error))
            }
        }
        return request
    }
}

// 参数转换
extension XYNetworkRequester {
    
    func URLForQueryItems(url: URL, parameters: Any?) -> URL {
        if var components = URLComponents(url: url, resolvingAgainstBaseURL: true) {
            var queryItems: [URLQueryItem] = []
            if let subQueryItems = components.queryItems {
                queryItems += subQueryItems
            }
            queryItems += self.queryItemsForParameters(key: nil, value: parameters)
            components.queryItems = queryItems
            if let url = components.url {
                return url
            }
        }
        return url
    }
    
    func queryString(parameters: Any?) -> String {
        let queryItems = self.queryItemsForParameters(key: nil, value: parameters)
        var queryArray: [String] = []
        for queryItem in queryItems {
            var string = ""
            if let key = queryItem.name.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
                string += key + "="
            }
            if let value = queryItem.value?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
                string += value
            }
            queryArray.append(string)
        }
        let string = queryArray.joined(separator: "&")
        return string
    }
    
    func queryItemsForParameters(key: String?, value: Any?) -> [URLQueryItem] {
        var queryItems: [URLQueryItem] = []
        if let key = key {
            if let dictionary = value as? [String: Any] {
                for (subKey, subValue) in dictionary {
                    let subQueryArray = queryItemsForParameters(key: "\(key)[\(subKey)]", value: subValue)
                    queryItems += subQueryArray
                }
            } else if let array = value as? [Any] {
                for (subItem) in array {
                    let subQueryArray = queryItemsForParameters(key: key, value: subItem)
                    queryItems += subQueryArray
                }
            } else if let value = value as? String {
                let queryItem = URLQueryItem(name: key, value: value)
                queryItems.append(queryItem)
            } else if let value = value {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                queryItems.append(queryItem)
            }
        } else {
            if let dictionary = value as? [String: Any] {
                for (subKey, subValue) in dictionary {
                    let subQueryItems = queryItemsForParameters(key: subKey, value: subValue)
                    queryItems += subQueryItems
                }
            }
        }
        return queryItems
    }
}
