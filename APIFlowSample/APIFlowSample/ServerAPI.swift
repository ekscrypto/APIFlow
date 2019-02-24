//
//  ServerAPI.swift
//  APIFlowSample
//
//  Created by Dave Poirier on 2019-02-23.
//  Copyright © 2019 Dave Poirier. All rights reserved.
//

import Foundation
import APIFlow

open class ServerAPI {
    
    public static func useDevEnvironment() {
        APIFlow.defaultHost = "localhost"
        APIFlow.defaultPort = 80
        APIFlow.defaultScheme = "http"
    }
    
    public static func anonymousPost<T: Encodable, R: Decodable>(
        endpoint: String,
        request: T,
        onSuccess: @escaping ((_: R) -> Void),
        onFailure: @escaping ((_: Error?) -> Void)) {
        
        let actions: [APIFlowAction] = [
            APIFlowAction.encode(request),
            APIFlowAction.generateURL(path: endpoint),
            APIFlowAction.generateRequest(
                method: "POST",
                headers: [
                    "Content-Type": "application/json",
                    "Accept": "application/json"
                ]),
            APIFlowAction.dispatch(),
//            APIFlowAction.dumpResponseData(),
            APIFlowAction.upon(
                decoding: R.self,
                do: { (response, _) -> APIFlow.FlowControl in
                    onSuccess(response)
                    return .end
            }),
            APIFlowAction.call({ (flow) -> APIFlow.FlowControl in
                onFailure(flow.request.error)
                return .end
            })
        ]
        try? APIFlow(actions: actions).resume()
    }
}
