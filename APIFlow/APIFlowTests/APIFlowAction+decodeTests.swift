//
//  APIFlowAction+decodeTests.swift
//  APIFlowTests
//
//  Created by Dave Poirier on 2019-02-23.
//  Copyright © 2019 Dave Poirier. All rights reserved.
//

import XCTest
@testable import APIFlow

class APIFlowAction_decodeTests: XCTestCase {

    struct SampleCodable: Codable {
        let simpleString: String
        let simpleInteger: Int
    }
    
    struct OtherCodable: Codable {
        let status: Int
        let message: String
    }

    func testCanDecodeProperlyFormattedCodable() {
        let randomInt = Int.random(in: 0...1000)
        let uuidString = UUID().uuidString
        let sampleCodable = SampleCodable(simpleString: uuidString, simpleInteger: randomInt)
        let request = APIFlowRequest()
        request.responseData = try! JSONEncoder().encode(sampleCodable)
        let decodeWasCalled = XCTestExpectation(description: "dataAction to be called")
        let decodeAction = APIFlowAction.upon(decoding: SampleCodable.self) { (decodedSample, _) in
            decodeWasCalled.fulfill()
            XCTAssertEqual(decodedSample.simpleString, uuidString)
            XCTAssertEqual(decodedSample.simpleInteger, randomInt)
            return .end
        }
        let flow = APIFlow(request: request, actions: [decodeAction])
        XCTAssertNoThrow(try flow.resume())
        wait(for: [decodeWasCalled], timeout: 0.1)
        XCTAssertEqual(flow.status, .endedByDecision)
    }
    
    func testSilentlyFailsDecodingUnexpectedCodable() {
        let randomInt = Int.random(in: 0...1000)
        let uuidString = UUID().uuidString
        let otherCodable = OtherCodable(status: randomInt, message: uuidString)
        let request = APIFlowRequest()
        request.responseData = try! JSONEncoder().encode(otherCodable)
        let randomName = UUID().uuidString
        let decodeAction = APIFlowAction.upon(decoding: SampleCodable.self, named: randomName) { (decodedSample, _) in
            XCTFail("This should not be called, data format should differ")
            return .threwException
        }
        let flow = APIFlow(request: request, actions: [decodeAction])
        XCTAssertNoThrow(try flow.resume())
        XCTAssertEqual(flow.status, .ended)
        XCTAssertEqual(flow.logs.count, 1)
        XCTAssertEqual(flow.logs[0].action.name, randomName)
        XCTAssertEqual(flow.logs[0].decision, .flowThrough)
    }
    
    func testSilentlyFailsWhenNoDataPresent() {
        let request = APIFlowRequest()
        request.responseData = nil
        let randomName = UUID().uuidString
        let decodeAction = APIFlowAction.upon(decoding: SampleCodable.self, named: randomName) { (decodedSample, _) in
            XCTFail("This should not be called, no data provided")
            return .threwException
        }
        let flow = APIFlow(request: request, actions: [decodeAction])
        XCTAssertNoThrow(try flow.resume())
        XCTAssertEqual(flow.status, .ended)
        XCTAssertEqual(flow.logs.count, 1)
        XCTAssertEqual(flow.logs[0].action.name, randomName)
        XCTAssertEqual(flow.logs[0].decision, .flowThrough)
    }
}
