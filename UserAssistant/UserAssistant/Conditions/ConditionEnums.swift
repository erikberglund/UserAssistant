//
//  ConditionsRequire.swift
//  UserAssistant
//
//  Created by Erik Berglund on 2018-08-30.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Foundation

enum ConditionError: Error {
    case invalidKey(String)
    case invalidValue(Any?, _ forKey: String)
    case invalidMatch(ConditionMatch, _ forKey: String)
}

enum ConditionsAction: String {
    case message
    case applicationBlock
    case applicationWarn
}

enum ConditionMatch: String {
    case equal
    case notEqual
    case contains
    case notContains
    case beginsWith
    case endsWith
    case greaterThan
    case greaterThanOrEqual
    case lessThan
    case lessThanOrEqual
}

enum ConditionStatus {
    case pass
    case failed
}
