//
//  APIFlow_FlowControlDecisionTests.swift
//  APIFlowTests
//
//  Created by Dave Poirier on 2019-02-23.
//  Copyright © 2019 Dave Poirier. All rights reserved.
//

import XCTest
@testable import APIFlow

class APIFlow_FlowControlDecisionTests: XCTestCase {
    
    enum Errors: Error {
        case generic
    }

    func testFlowEndsOnFlowControlEnd() {
        let actionWasCalled = XCTestExpectation(description: "end action to be called")
        let endAction = APIFlowHelpers.actionWithFlowControl(
            flowControl: .end,
            expectation: actionWasCalled)
        
        let flow = APIFlow(name: #function, actions: [
            endAction,
            APIFlowHelpers.actionThatShouldNotBeCalled()])

        XCTAssertNoThrow(try flow.resume())
        wait(for: [actionWasCalled], timeout: 0.1)
        XCTAssertEqual(flow.status, .endedByDecision)
    }
    
    func testFlowEndsOnFlowControlThrewException() {
        let actionWasCalled = XCTestExpectation(description: "end action to be called")
        let endAction = APIFlowHelpers.actionWithFlowControl(
            flowControl: .threwException,
            expectation: actionWasCalled)
        
        let flow = APIFlow(name: #function, actions: [
            endAction,
            APIFlowHelpers.actionThatShouldNotBeCalled()])
        
        XCTAssertNoThrow(try flow.resume())
        wait(for: [actionWasCalled], timeout: 0.1)
        XCTAssertEqual(flow.status, .endedByThrowable)
    }
    
    func testFlowContinuesOnFlowControlFlowThrough() {
        let firstActionWasCalled = XCTestExpectation(description: "first action to be called")
        let firstAction = APIFlowHelpers.actionWithFlowControl(
            flowControl: .flowThrough,
            expectation: firstActionWasCalled)
        
        let flow = APIFlow(name: #function, actions: [
            firstAction])
        XCTAssertNoThrow(try flow.resume())
        wait(for: [firstActionWasCalled], timeout: 0.1)
        XCTAssertEqual(flow.status, .ended)
    }

    func testFlowPausesOnFlowControlWaitForAsyncDecision() {
        let waitActionWasCalled = XCTestExpectation(description: "wait action to be called")
        let waitAction = APIFlowHelpers.actionWithFlowControl(
            flowControl: .waitForAsyncDecision,
            expectation: waitActionWasCalled)
        
        let flow = APIFlow(name: #function, actions: [
            waitAction,
            APIFlowHelpers.actionThatShouldNotBeCalled()])
        
        XCTAssertNoThrow(try flow.resume())
        wait(for: [waitActionWasCalled], timeout: 0.1)
        XCTAssertEqual(flow.status, .waitingForAsyncDecision)
    }
    
    func testFlowEndsIfExecutionExceptionGenerated() {
        let errorAction = APIFlowHelpers.actionWithError(Errors.generic)
        let flow = APIFlow(name: #function, actions: [errorAction])
        XCTAssertThrowsError(try flow.resume())
        XCTAssertEqual(flow.status, .endedByThrowable)
    }
}
