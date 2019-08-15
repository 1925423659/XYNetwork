//
//  XYNetworkResponseSerializer.swift
//  HTTPRequest
//
//  Created by 白野 on 2019/8/12.
//  Copyright © 2019 白野. All rights reserved.
//
//  响应器，用于解析响应数据

import UIKit

class XYNetworkResponser: NSObject {
    func response(data: Data) throws -> Any {
        do {
            return try JSONSerialization.jsonObject(with: data, options: [])
        } catch {
            throw XYNetworkError.responseSerializationFailed(reason: .jsonSerializationFailed(error: error))
        }
    }
}
