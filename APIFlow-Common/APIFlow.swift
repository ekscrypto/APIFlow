//
//  APIFlow.swift
//  TestProject-00387
//
//  Created by Dave Poirier on 2019-02-23.
//  Copyright © 2019 Appcom. All rights reserved.
//

import Foundation

class APIFlow {

    public enum FlowControl {
        case flowThrough
        case waitForAsyncDecision
        case end
        case threwException
    }

    public struct Log {
        let action: APIFlowAction
        let decision: FlowControl
    }

    public enum Status {
        case initialized
        case executing
        case waitingForAsyncDecision
        case endedByThrowable
        case endedByDecision
        case ended
    }
    
    public enum Errors: Error {
        case unexpectedStatus
    }

    public static var defaultScheme: String = "https"
    public static var defaultHost: String = "localhost"
    public static var defaultPort: Int = 443

    public let name: String
    public private(set) var logs: [Log]
    public private(set) var status: Status
    public let request: APIFlowRequest

    private let actions: [APIFlowAction]
    private var nextAction: Int = 0
    private let lock = NSLock()

    init(name: String = "", request: APIFlowRequest = APIFlowRequest(), actions: [APIFlowAction]) {
        self.name = name
        self.request = request
        self.actions = actions
        self.logs = []
        self.status = .initialized
    }

    public func resume(asyncDecision: FlowControl? = nil) throws {
        lock.lock()
        guard (
            (status == .initialized && asyncDecision == nil) ||
            (status == .waitingForAsyncDecision && asyncDecision != nil)
            )
            else {
                lock.unlock()
                throw Errors.unexpectedStatus
        }

        if let decision = asyncDecision {
            switch decision {
            case .flowThrough:
                break
            case .end:
                status = .endedByDecision
            case .waitForAsyncDecision:
                status = .waitingForAsyncDecision
            case .threwException:
                status = .endedByThrowable
            }
            if decision != .flowThrough {
                lock.unlock()
                return
            }
        }

        status = .executing
        while nextAction < actions.count {
            let flowAction = actions[nextAction]
            nextAction += 1

            do {
                let decision = try flowAction.action(self)
                logs.append(Log(action: flowAction, decision: decision))

                switch decision {
                case .flowThrough:
                    break
                case .end:
                    status = .endedByDecision
                case .waitForAsyncDecision:
                    status = .waitingForAsyncDecision
                case .threwException:
                    status = .endedByThrowable
                }
                if decision != .flowThrough {
                    lock.unlock()
                    return
                }
            } catch {
                logs.append(Log(action: flowAction, decision: .threwException))
                status = .endedByThrowable
                request.error = error
                lock.unlock()
                throw error
            }
        }
        status = .ended
        lock.unlock()
    }
}
