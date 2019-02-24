//
//  APIFlowAction+decode.swift
//  TestProject-00387
//
//  Created by Dave Poirier on 2019-02-23.
//  Copyright © 2019 Appcom. All rights reserved.
//

import Foundation

extension APIFlowAction {
    public static func upon<T: Decodable>(
        decoding: T.Type,
        named actionName: String? = nil,
        do successAction: @escaping ((_: T, _: APIFlowRequest) -> APIFlow.FlowControl))
        -> APIFlowAction
    {
        let action: APIFlowAction.Action = { (flow) in
            guard let data = flow.request.responseData else { return APIFlow.FlowControl.flowThrough }
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                return successAction(decoded, flow.request)
            } catch {
                return APIFlow.FlowControl.flowThrough
            }
        }
        return APIFlowAction(name: actionName ?? "JSONDecoder.decode \(T.self)", action: action)
    }
}
