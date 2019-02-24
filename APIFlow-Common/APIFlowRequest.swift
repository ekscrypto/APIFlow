//
//  APIFlow+Request.swift
//  TestProject-00387
//
//  Created by Dave Poirier on 2019-02-23.
//  Copyright © 2019 Appcom. All rights reserved.
//

import Foundation

public class APIFlowRequest {
    public var url: URL?
    public var urlRequest: URLRequest?
    public var urlSession: URLSession?
    public var requestData: Data?
    public var responseData: Data?
    public var urlResponse: URLResponse?
    public var error: Error?
}
