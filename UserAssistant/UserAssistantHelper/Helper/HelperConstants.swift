//
//  HelperConstants.swift
//  com.github.erikberglund.UserAssistantHelper
//
//  Created by Erik Berglund.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Cocoa

let kAuthorizationRightKeyClass     = "class"
let kAuthorizationRightKeyGroup     = "group"
let kAuthorizationRightKeyRule      = "rule"
let kAuthorizationRightKeyTimeout   = "timeout"
let kAuthorizationRightKeyVersion   = "version"

let kAuthorizationFailedExitCode    = NSNumber(value: 503340)

struct HelperConstants {
    static let machServiceName = "com.github.erikberglund.UserAssistantHelper"
}
