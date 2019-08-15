//
//  XYNetworkResponse.swift
//  HTTPRequest
//
//  Created by 白野 on 2019/8/13.
//  Copyright © 2019 白野. All rights reserved.
//
//  容器，用于保存请求和响应数据

import UIKit

class XYNetworkContainer: NSObject {
    var request: URLRequest?
    var responseString: String?
    var responseObject: Any?
    var error: Error?
}
