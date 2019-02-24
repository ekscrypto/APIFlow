//
//  ServerAPI+login.swift
//  APIFlowSample
//
//  Created by Dave Poirier on 2019-02-23.
//  Copyright © 2019 Dave Poirier. All rights reserved.
//

import Foundation
import APIFlow

extension ServerAPI {
    
    public struct LoginRequest: Encodable {
        let email: String
        let password: String
    }
    
    public struct LoginResponse: Decodable {
        let status: String
        let accesstoken: String
        let refreshtoken: String
        let expiresin: Int
    }
}

extension ServerAPI.LoginRequest {
    public func dispatch(
        onSuccess successHandler: @escaping ((_: ServerAPI.LoginResponse) -> Void),
        onFailure failureHandler: @escaping (() -> Void)) {

        ServerAPI.anonymousPost(
            endpoint: "/api/login",
            request: self,
            onSuccess: successHandler,
            onFailure: { (_) in failureHandler() })
    }
}
