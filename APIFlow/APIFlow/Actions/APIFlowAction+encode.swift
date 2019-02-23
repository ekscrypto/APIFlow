//
//  APIFlowAction+encode.swift
//  APIFlow
//
//  Created by Dave Poirier on 2019-02-23.
//  Copyright © 2019 Dave Poirier. All rights reserved.
//

import Foundation

extension APIFlowAction {
    public static func encode<T: Encodable>(
        _ encodable: T)
        -> APIFlowAction
    {
        return APIFlowAction(name: "JSONEncoder.encode", action: { (flow) -> APIFlow.FlowControl in
            let encodedData = try JSONEncoder().encode(encodable)
            flow.request.requestData = encodedData
            return APIFlow.FlowControl.flowThrough
        })
    }
}
