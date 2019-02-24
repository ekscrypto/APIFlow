//
//  APIFlow+Actions.swift
//  TestProject-00387
//
//  Created by Dave Poirier on 2019-02-23.
//  Copyright © 2019 Appcom. All rights reserved.
//

public class APIFlowAction {

    typealias Action = ((_: APIFlow) throws -> APIFlow.FlowControl)

    let name: String
    let action: Action

    init(name: String, action: @escaping Action) {
        self.name = name
        self.action = action
    }
}
