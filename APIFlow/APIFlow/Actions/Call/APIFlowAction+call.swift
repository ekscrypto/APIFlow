//
//  APIFlowAction+call.swift
//  APIFlow
//
//  Created by Dave Poirier on 2019-02-23.
//  Copyright © 2019 Dave Poirier. All rights reserved.
//

import Foundation

extension APIFlowAction {
    public static func call(
        named actionName: String = "call",
        _ action: @escaping ((_: APIFlow) -> APIFlow.FlowControl))
        -> APIFlowAction
    {
        return APIFlowAction(name: actionName, action: action)
    }
}
