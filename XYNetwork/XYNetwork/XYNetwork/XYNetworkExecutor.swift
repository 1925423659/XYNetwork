//
//  XYNetworkDataTask.swift
//  HTTPRequest
//
//  Created by 白野 on 2019/8/13.
//  Copyright © 2019 白野. All rights reserved.
//
//  执行器，用于生成网络请求任务

import UIKit

class XYNetworkExecutor: NSObject {
    weak var session: URLSession?
    weak var responser: XYNetworkResponser?
    
    init(session: URLSession?, responser: XYNetworkResponser?) {
        super.init()
        
        self.session = session
        self.responser = responser
    }
    
    func dataTask(container: XYNetworkContainer, completion: ((XYNetworkContainer) -> Void)?) -> URLSessionDataTask? {
        guard let session = self.session else {
            container.error = XYNetworkError.sessionUninitialized
            XYNetworkExecutor.complete(container: container, completion: completion)
            return nil
        }
        guard let responser = self.responser else {
            container.error = XYNetworkError.responserUninitialized
            XYNetworkExecutor.complete(container: container, completion: completion)
            return nil
        }
        guard let request = container.request else {
            container.error = XYNetworkError.invalidRequest
            XYNetworkExecutor.complete(container: container, completion: completion)
            return nil
        }

        let completionHandler: ((Data?, URLResponse?, Error?) -> Void) = { (data, response, error) in
            if let error = error {
                container.error = error
                XYNetworkExecutor.complete(container: container, completion: completion)
                return
            }
            if let data = data {
                container.responseString = String(data: data, encoding: String.Encoding.utf8)
                do {
                    container.responseObject = try responser.response(data: data)
                    XYNetworkExecutor.complete(container: container, completion: completion)
                } catch {
                    container.error = error
                    XYNetworkExecutor.complete(container: container, completion: completion)
                }
            }
        }

        return session.dataTask(with: request, completionHandler: completionHandler)
    }
    
    class func complete(container: XYNetworkContainer, completion: ((XYNetworkContainer) -> Void)?) {
        if completion == nil && container.error != nil {
            print("network error", container.error as Any)
        } else {
            DispatchQueue.main.async {
                completion?(container)
            }
        }
    }
}
