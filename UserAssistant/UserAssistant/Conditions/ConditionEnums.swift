//
//  ConditionsRequire.swift
//  UserAssistant
//
//  Created by Erik Berglund on 2018-08-30.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Foundation

enum ConditionsRequire: String {
    case any
    case all
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
