//
//  APIFlowAction+dumpResponseData.swift
//  APIFlow
//
//  Created by Dave Poirier on 2019-02-23.
//  Copyright © 2019 Dave Poirier. All rights reserved.
//

import Foundation

extension APIFlowAction {
    public static func dumpResponseData()
        -> APIFlowAction
    {
        return APIFlowAction(name: "dumpResponseData", action: { (flow) -> APIFlow.FlowControl in
            if let data = flow.request.responseData,
                let string = String(data: data, encoding: String.Encoding.utf8) {
                print("APIFlow Response Data (as UTF-8 String):\n\(string)")
            }
            return .flowThrough
        })
    }
}
