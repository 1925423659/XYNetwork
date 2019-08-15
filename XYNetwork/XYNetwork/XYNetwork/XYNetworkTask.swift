//
//  XYNetworkDataTask.swift
//  HTTPRequest
//
//  Created by 白野 on 2019/8/13.
//  Copyright © 2019 白野. All rights reserved.
//
//  任务，用于执行网络请求任务

import UIKit

class XYNetworkTask: NSObject {
    var container: XYNetworkContainer = XYNetworkContainer()
    var stop: Bool = false
    
    weak var requester: XYNetworkRequester?
    weak var responser: XYNetworkResponser?
    weak var executor: XYNetworkExecutor?
    
    init(requester: XYNetworkRequester?, responser: XYNetworkResponser?, executor: XYNetworkExecutor?) {
        super.init()
        
        self.requester = requester
        self.responser = responser
        self.executor = executor
    }
    
    func request(baseURLString: String, URLString: String, httpMethod: String?, allHTTPHeaderFields: [String : String]?) -> XYNetworkTask {
        if self.stop {
            return self
        }
        
        guard let requester = self.requester else {
            self.stop = true
            self.container.error = XYNetworkError.requesterUninitialized
            XYNetworkExecutor.complete(container: self.container, completion: nil)
            return self
        }
        
        do {
            self.container.request = try requester.request(baseURLString: baseURLString, URLString: URLString, httpMethod: httpMethod, allHTTPHeaderFields: allHTTPHeaderFields)
        } catch {
            self.stop = true
            self.container.error = error
            XYNetworkExecutor.complete(container: self.container, completion: nil)
            return self
        }
        
        return self
    }
    
    func parameters(type: XYNetworkRequestType, parameters: Any?) -> XYNetworkTask {
        if self.stop {
            return self
        }
        
        guard let requester = self.requester else {
            self.stop = true
            self.container.error = XYNetworkError.requesterUninitialized
            XYNetworkExecutor.complete(container: self.container, completion: nil)
            return self
        }
        guard var request = self.container.request else {
            self.stop = true
            self.container.error = XYNetworkError.invalidRequest
            XYNetworkExecutor.complete(container: self.container, completion: nil)
            return self
        }
        
        if type == .URL {
            self.container.request = requester.URLParameters(request: &request, parameters: parameters)
        } else if type == .HTTPBodyString {
            self.container.request = requester.stringParameters(request: &request, parameters: parameters)
        } else if type == .HTTPBodyJSON {
            do {
                self.container.request = try requester.JSONParameters(request: &request, parameters: parameters)
            } catch {
                self.stop = true
                self.container.error = error
                XYNetworkExecutor.complete(container: self.container, completion: nil)
                return self
            }
        }
        
        return self
    }
    
    func response(completion: ((XYNetworkContainer) -> Void)?) {
        if self.stop {
            return
        }
        
        guard let executor = self.executor else {
            self.stop = true
            self.container.error = XYNetworkError.dataTaskUninitialized
            XYNetworkExecutor.complete(container: self.container, completion: completion)
            return
        }

        let dataTask = executor.dataTask(container: self.container, completion: completion)
        dataTask?.resume()
    }
}

extension XYNetworkTask {
    func POSTRequest(baseURLString: String, URLString: String, allHTTPHeaderFields: [String : String]?) -> XYNetworkTask {
        return self.request(baseURLString: baseURLString, URLString: URLString, httpMethod: "POST", allHTTPHeaderFields: allHTTPHeaderFields)
    }
    
    func GETRequest(baseURLString: String, URLString: String, allHTTPHeaderFields: [String : String]?) -> XYNetworkTask {
        return self.request(baseURLString: baseURLString, URLString: URLString, httpMethod: "GET", allHTTPHeaderFields: allHTTPHeaderFields)
    }
    
    func URLParameters(parameters: Any?) -> XYNetworkTask {
        return self.parameters(type: .URL, parameters: parameters)
    }
    
    func StringParameters(parameters: Any?) -> XYNetworkTask {
        return self.parameters(type: .HTTPBodyString, parameters: parameters)
    }
    
    func JSONParameters(parameters: Any?) -> XYNetworkTask {
        return self.parameters(type: .HTTPBodyJSON, parameters: parameters)
    }
}
