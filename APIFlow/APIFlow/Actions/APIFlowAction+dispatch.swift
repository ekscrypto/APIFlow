//
//  APIFlowAction+dispatch.swift
//  APIFlow
//
//  Created by Dave Poirier on 2019-02-23.
//  Copyright © 2019 Dave Poirier. All rights reserved.
//

import Foundation

extension APIFlowAction {
    public static func dispatch()
        -> APIFlowAction
    {
        enum Errors: Error {
            case missingUrlOrUrlRequest
        }
        
        return APIFlowAction(
            name: "URLSession.dataTask.dispatch",
            action: { (flow) -> APIFlow.FlowControl in
                let urlSession = flow.request.urlSession ?? URLSession.shared
                let completionHandler: ((_: Data?, _: URLResponse?, _: Error?) -> Void) = {
                    (dataOrNil, urlResponseOrNil, errorOrNil) in
                    flow.request.error = errorOrNil
                    flow.request.urlResponse = urlResponseOrNil
                    flow.request.responseData = dataOrNil
                    DispatchQueue.main.async {
                        try? flow.resume(asyncDecision: .flowThrough)
                    }
                }
                if let urlRequest = flow.request.urlRequest {
                    DispatchQueue.global().async {
                        urlSession.dataTask(
                            with: urlRequest,
                            completionHandler: completionHandler)
                    }
                } else if let url = flow.request.url {
                    DispatchQueue.global().async {
                        urlSession.dataTask(
                            with: url,
                            completionHandler: completionHandler)
                    }
                } else {
                    throw Errors.missingUrlOrUrlRequest
                }
                return .waitForAsyncDecision
        })
    }
}
