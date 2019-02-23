//
//  APIFlow_ResumeLogicTests.swift
//  APIFlowTests
//
//  Created by Dave Poirier on 2019-02-23.
//  Copyright © 2019 Dave Poirier. All rights reserved.
//

import XCTest
@testable import APIFlow

class APIFlow_ResumeLogicTests: XCTestCase {

    func testCannotResumeWithDecisionOnNewFlow() {
        let flow = APIFlow(name: #function, actions: [])
        XCTAssertThrowsError(
            try flow.resume(asyncDecision: .end),
            "Providing a decision on a new flow, which is not waiting for a decision, should not be allowed"
        ) { (error) in
            XCTAssertEqual(error as? APIFlow.Errors, APIFlow.Errors.unexpectedStatus)
        }
        XCTAssertEqual(flow.status, .initialized)
    }
    
    func testAsyncResumeWithFlowThroughContinuesToNextAction() {
        let afterResumeWasCalled = XCTestExpectation(description: "after resume action to be called")
        var afterResumeActionExecuted = false
        let afterResumeAction = APIFlowHelpers.actionWithFlowControl(
            flowControl: .flowThrough,
            expectation: afterResumeWasCalled) {
                afterResumeActionExecuted = true
        }
        
        let flow = APIFlowHelpers.flowInWaitingState([afterResumeAction])
        XCTAssertEqual(flow.status, .waitingForAsyncDecision)
        XCTAssertFalse(afterResumeActionExecuted)
        XCTAssertNoThrow(try flow.resume(asyncDecision: .flowThrough))
        wait(for: [afterResumeWasCalled], timeout: 0.1)
        XCTAssertTrue(afterResumeActionExecuted)
        XCTAssertEqual(flow.status, .ended)
    }

    func testAsyncResumeWithEndDoesNotExecuteFurtherActions() {
        let flow = APIFlowHelpers.flowInWaitingState([APIFlowHelpers.actionThatShouldNotBeCalled()])
        XCTAssertEqual(flow.status, .waitingForAsyncDecision)
        XCTAssertNoThrow(try flow.resume(asyncDecision: .end))
        XCTAssertEqual(flow.status, .endedByDecision)
    }

    func testAsyncResumeWithWaitingForAsyncDecisionExecutesNoFurtherActions() {
        let flow = APIFlowHelpers.flowInWaitingState([APIFlowHelpers.actionThatShouldNotBeCalled()])
        XCTAssertEqual(flow.status, .waitingForAsyncDecision)
        XCTAssertNoThrow(try flow.resume(asyncDecision: .waitForAsyncDecision))
        XCTAssertEqual(flow.status, .waitingForAsyncDecision)
    }
    
    func testAsyncResumeWithThrewExceptionExecutesNoFurtherActions() {
        let flow = APIFlowHelpers.flowInWaitingState([APIFlowHelpers.actionThatShouldNotBeCalled()])
        XCTAssertEqual(flow.status, .waitingForAsyncDecision)
        XCTAssertNoThrow(try flow.resume(asyncDecision: .threwException))
        XCTAssertEqual(flow.status, .endedByThrowable)
    }
    
    func testCannotResumeWithoutDecisionWhenWaitingForDecision() {
        let flow = APIFlowHelpers.flowInWaitingState([APIFlowHelpers.actionThatShouldNotBeCalled()])
        XCTAssertEqual(flow.status, .waitingForAsyncDecision)
        XCTAssertThrowsError(
            try flow.resume(),
            "resuming without any decision a flow waiting for a decision is not allowed"
        ) { (error) in
            XCTAssertEqual(error as? APIFlow.Errors, APIFlow.Errors.unexpectedStatus)
        }
        XCTAssertEqual(flow.status, .waitingForAsyncDecision)
    }
    
    func testCannotResumeEndedFlows() {
        let flow = APIFlowHelpers.flowInEndedState()
        XCTAssertEqual(flow.status, .ended)

        XCTAssertThrowsError(
            try flow.resume(asyncDecision: .flowThrough),
            "resuming ended flows should not be allowed"
        ) {
            (error) in
            XCTAssertEqual(error as? APIFlow.Errors, APIFlow.Errors.unexpectedStatus)
        }
    }
}
