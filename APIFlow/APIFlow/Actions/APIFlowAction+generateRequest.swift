//
//  APIFlowAction+generateRequest.swift
//  TestProject-00387
//
//  Created by Dave Poirier on 2019-02-23.
//  Copyright © 2019 Appcom. All rights reserved.
//

import Foundation

extension APIFlowAction {
    public static func generateRequest(
        url: URL? = nil,
        method: String = "GET",
        cachePolicy: URLRequest.CachePolicy = URLRequest.CachePolicy.returnCacheDataElseLoad,
        timeoutInterval: TimeInterval = 60.0,
        headers: [String: String?] = [:],
        queryParameters: [String: String] = [:])
        -> APIFlowAction {
        let action: APIFlowAction.Action = { (flow) in
            
            enum Errors: Error {
                case missingUrl
            }

            guard let effectiveUrl = url ?? flow.request.url else {
                throw Errors.missingUrl
            }

            var urlRequest = URLRequest(url: effectiveUrl, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
            urlRequest.httpMethod = method
            urlRequest.httpBody = flow.request.requestData
            for (name, value) in headers {
                urlRequest.setValue(value, forHTTPHeaderField: name)
            }
            flow.request.urlRequest = urlRequest
            return APIFlow.FlowControl.flowThrough
        }
        return APIFlowAction(name: "Generate \(method) request", action: action)
    }
}
