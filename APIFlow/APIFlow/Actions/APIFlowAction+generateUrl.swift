//
//  APIFlowAction+generateUrl.swift
//  TestProject-00387
//
//  Created by Dave Poirier on 2019-02-23.
//  Copyright © 2019 Appcom. All rights reserved.
//

import Foundation

extension APIFlowAction {
    public static func generateURL(
        scheme: String = APIFlow.defaultScheme,
        host: String = APIFlow.defaultHost,
        port: Int = APIFlow.defaultPort,
        path: String = "",
        queryParameters: [String: String?] = [:])
        -> APIFlowAction {
        let action: APIFlowAction.Action = { (flow) in
            var urlComponents = URLComponents()
            urlComponents.scheme = scheme
            urlComponents.host = host
            urlComponents.port = port
            urlComponents.path = path
            var queryItems: [URLQueryItem] = []
            for (name, value) in queryParameters {
                let queryItem = URLQueryItem(name: name, value: value)
                queryItems.append(queryItem)
            }
            if queryItems.count > 0 {
                urlComponents.queryItems = queryItems
            }
            flow.request.url = urlComponents.url?.absoluteURL
            return APIFlow.FlowControl.flowThrough
        }
        return APIFlowAction(name: "Generate URL", action: action)
    }
}
