//
//  APIFlow_ActionsHandlingTests.swift
//  APIFlowTests
//
//  Created by Dave Poirier on 2019-02-23.
//  Copyright © 2019 Dave Poirier. All rights reserved.
//

import XCTest
@testable import APIFlow

class APIFlow_ActionsHandlingTests: XCTestCase {

    func testEmptyFlowEndsWithStatusEnded() {
        let flow = APIFlow(name: #function, request: APIFlowRequest(), actions: [])
        XCTAssertNoThrow(try flow.resume())
        XCTAssertEqual(flow.status, .ended)
    }
    
    func testActionsAreExecutedInOrder() {
        var expectations = [XCTestExpectation]()
        var actions = [APIFlowAction]()
        var calledSoFar: Int = 0
        for i in 1...5 {
            let expectation = XCTestExpectation(description: "\(i) action to be called")
            let action = APIFlowHelpers.actionWithFlowControl(
                flowControl: .flowThrough,
                expectation: expectation) {
                    calledSoFar += 1
                    XCTAssertEqual(calledSoFar, i)
            }
            expectations.append(expectation)
            actions.append(action)
        }
        
        let flow = APIFlow(name: #function, actions: actions)
        
        XCTAssertNoThrow(try flow.resume())
        wait(for: expectations, timeout: 0.1, enforceOrder: true)
        XCTAssertEqual(flow.status, .ended)
    }
}
