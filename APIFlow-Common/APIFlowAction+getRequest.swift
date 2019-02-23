//
//  APIFlowAction+getRequest.swift
//  TestProject-00387
//
//  Created by Dave Poirier on 2019-02-23.
//  Copyright © 2019 Appcom. All rights reserved.
//

import Foundation

extension APIFlowAction {
    public static func prepareGetRequest(
        url: URL? = nil,
        cachePolicy: URLRequest.CachePolicy = URLRequest.CachePolicy.returnCacheDataElseLoad,
        timeoutInterval: TimeInterval = 60.0,
        headers: [String: String?] = [:],
        queryParameters: [String: String] = [:])
        -> APIFlowAction {
        let action: APIFlowAction.Action = { (flow) in
            guard let effectiveUrl = url ?? flow.request.url else {
                return APIFlow.FlowControl.end
            }
            var urlRequest = URLRequest(url: effectiveUrl, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
            for (name, value) in headers {
                urlRequest.setValue(value, forHTTPHeaderField: name)
            }
            flow.request.urlRequest = urlRequest
            return APIFlow.FlowControl.flowThrough
        }
        return APIFlowAction(name: "Generate GET request", action: action)
    }
}
