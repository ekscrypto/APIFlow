//
//  APIFlow+Request.swift
//  TestProject-00387
//
//  Created by Dave Poirier on 2019-02-23.
//  Copyright © 2019 Appcom. All rights reserved.
//

import Foundation

class APIFlowRequest {
    var url: URL?
    var urlRequest: URLRequest?
    var urlSession: URLSession?
    var data: Data?
    var urlResponse: URLResponse?
    var error: Error?
}
