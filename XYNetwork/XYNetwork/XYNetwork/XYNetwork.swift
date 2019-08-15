//
//  HTTPRequest.swift
//  HTTPRequest
//
//  Created by 白野 on 2019/8/12.
//  Copyright © 2019 白野. All rights reserved.
//

import UIKit

enum XYNetworkRequestType : Int {
    case URL
    case HTTPBodyString
    case HTTPBodyJSON
}

class XYNetwork: NSObject {

    static let sharedInstance = XYNetwork()
    
    var session: URLSession?
    var requester: XYNetworkRequester?
    var responser: XYNetworkResponser?
    var executor: XYNetworkExecutor?

    class func create(configuration: URLSessionConfiguration) {
        let session = URLSession(configuration: configuration)
        self.sharedInstance.session = session
        self.sharedInstance.requester = XYNetworkRequester()
        let responser = XYNetworkResponser()
        self.sharedInstance.responser = responser
        self.sharedInstance.executor = XYNetworkExecutor(session: session, responser: responser)
    }
}

extension XYNetwork {
    class func POSTRequest(baseURLString: String, URLString: String, allHTTPHeaderFields: [String : String]?) -> XYNetworkTask {
        let task = XYNetworkTask(requester: self.sharedInstance.requester, responser: self.sharedInstance.responser, executor: self.sharedInstance.executor)
        return task.POSTRequest(baseURLString: baseURLString, URLString: URLString, allHTTPHeaderFields: allHTTPHeaderFields)
    }
    
    class func GETRequest(baseURLString: String, URLString: String, allHTTPHeaderFields: [String : String]?) -> XYNetworkTask {
        let task = XYNetworkTask(requester: self.sharedInstance.requester, responser: self.sharedInstance.responser, executor: self.sharedInstance.executor)
        return task.GETRequest(baseURLString: baseURLString, URLString: URLString, allHTTPHeaderFields: allHTTPHeaderFields)
    }
}

extension XYNetwork {
    class func network(baseURLString: String, URLString: String, httpMethod: String?, allHTTPHeaderFields: [String : String]?, type: XYNetworkRequestType, parameters: Any?, completion: ((XYNetworkContainer) -> Void)?) {
        let container = XYNetworkContainer()
        
        guard let requester = self.sharedInstance.requester else {
            container.error = XYNetworkError.requesterUninitialized
            XYNetworkExecutor.complete(container: container, completion: completion)
            return
        }
        guard let executor = self.sharedInstance.executor else {
            container.error = XYNetworkError.dataTaskUninitialized
            XYNetworkExecutor.complete(container: container, completion: completion)
            return
        }

        do {
            var request = try requester.request(baseURLString: baseURLString, URLString: URLString, httpMethod: httpMethod, allHTTPHeaderFields: allHTTPHeaderFields)
            if type == .URL {
                request = requester.URLParameters(request: &request, parameters: parameters)
            } else if type == .HTTPBodyString {
                request = requester.stringParameters(request: &request, parameters: parameters)
            } else if type == .HTTPBodyJSON {
                request = try requester.JSONParameters(request: &request, parameters: parameters)
            }
            container.request = request
            let dataTask = executor.dataTask(container: container, completion: completion)
            dataTask?.resume()
        } catch {
            container.error = error
            XYNetworkExecutor.complete(container: container, completion: completion)
            return
        }
    }
    
    class func POST(baseURLString: String, URLString: String, allHTTPHeaderFields: [String : String]?, type: XYNetworkRequestType, parameters: Any?, completion: ((XYNetworkContainer) -> Void)?) {
        self.network(baseURLString: baseURLString, URLString: URLString, httpMethod: "POST", allHTTPHeaderFields: allHTTPHeaderFields, type: type, parameters: parameters, completion: completion)
    }
    
    class func GET(baseURLString: String, URLString: String, allHTTPHeaderFields: [String : String]?, type: XYNetworkRequestType, parameters: Any?, completion: ((XYNetworkContainer) -> Void)?) {
        self.network(baseURLString: baseURLString, URLString: URLString, httpMethod: "GET", allHTTPHeaderFields: allHTTPHeaderFields, type: type, parameters: parameters, completion: completion)
    }
}
