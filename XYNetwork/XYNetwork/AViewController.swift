//
//  ViewController.swift
//  HTTPRequest
//
//  Created by 白野 on 2019/8/12.
//  Copyright © 2019 白野. All rights reserved.
//

import UIKit

class AViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func postButtonClick() {
        print("post button click")
        let allHTTPHeaderFields: [String: String] = ["from": "iPhone 6s 64",
                                                     "where": "中软",
                                                     "work": "iOS"]
        let parameters: [String: Any] = ["user": "baiye",
                                         "id": "001",
                                         "level": 60,
                                         "work": ["where": "zhong ruan",
                                                  "job": "iOS",
                                                  "have": ["phone", "computer"]]]
//        let parameters: [String] = ["iPhone", "Mac", "iPad"]
//        let parameters: [String: Any] = ["have": ["iPhone", "Mac", "iPad"]]
        
        XYNetwork.POSTRequest(baseURLString: "http://192.168.2.244:8000", URLString: "/network/post", allHTTPHeaderFields: allHTTPHeaderFields).StringParameters(parameters: parameters).response(completion: { (container) in
            print("get button click", container.error as Any, container.responseObject as Any, container.responseString as Any)
        })
    }
    
    @IBAction func getButtonClick() {
        print("get button click")
        let allHTTPHeaderFields: [String: String] = ["from": "iPhone 6s 64",
                                                     "where": "中软",
                                                     "work": "iOS"]
        let parameters: [String: Any] = ["user": "baiye",
                                         "id": "001",
                                         "level": 60,
                                         "work": ["where": "zhong ruan",
                                                  "job": "iOS",
                                                  "have": ["phone", "computer"]]]
//        let parameters: [String] = ["iPhone", "Mac", "iPad"]
//        let parameters: [String: Any] = ["have": ["iPhone", "Mac", "iPad"]]
        XYNetwork.GETRequest(baseURLString: "http://192.168.2.244:8000", URLString: "/network/post", allHTTPHeaderFields: allHTTPHeaderFields).URLParameters(parameters: parameters).response(completion: { (container) in
            print("get button click", container.error as Any, container.responseObject as Any, container.responseString as Any)
        })
    }
}
