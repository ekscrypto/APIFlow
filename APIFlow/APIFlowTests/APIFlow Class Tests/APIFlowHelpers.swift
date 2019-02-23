//
//  Helpers.swift
//  APIFlowTests
//
//  Created by Dave Poirier on 2019-02-23.
//  Copyright © 2019 Dave Poirier. All rights reserved.
//

import XCTest
@testable import APIFlow

class APIFlowHelpers {
    public static func actionThatShouldNotBeCalled() -> APIFlowAction {
        return APIFlowAction(name: #function, action: { (_) -> APIFlow.FlowControl in
            XCTFail("This action should not be called")
            return .end
        })
    }
    
    public static func actionWithFlowControl(
        flowControl: APIFlow.FlowControl,
        expectation: XCTestExpectation,
        additionalAction: (() -> Void)? = nil)
        -> APIFlowAction
    {
        return APIFlowAction(name: #function, action: { (_) -> APIFlow.FlowControl in
            expectation.fulfill()
            additionalAction?()
            return flowControl
        })
    }

    public static func actionWithError(_ error: Error) -> APIFlowAction {
        return APIFlowAction(name: #function, action: { (_) -> APIFlow.FlowControl in
            throw error
        })
    }

    public static func flowInWaitingState(_ otherActions: [APIFlowAction] = []) -> APIFlow {
        let waitActionWasCalled = XCTestExpectation(description: "wait action was called")
        let waitAction = APIFlowHelpers.actionWithFlowControl(
            flowControl: .waitForAsyncDecision,
            expectation: waitActionWasCalled)
        
        let allActions = [waitAction] + otherActions
        let flow = APIFlow(name: #function, actions: allActions)
        
        XCTAssertNoThrow(try flow.resume())
        return flow
    }
    
    public static func flowInEndedState() -> APIFlow {
        let flow = APIFlow(name: #function, actions: [])
        XCTAssertNoThrow(try flow.resume())
        return flow
    }
    
}
