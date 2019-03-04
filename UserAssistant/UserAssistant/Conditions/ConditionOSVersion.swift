//
//  ConditionOSVersion.swift
//  UserAssistant
//
//  Created by Erik Berglund on 2018-08-30.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Foundation

extension ConditionItem {
    func verifyOSVersion(completionHandler: (_ conditionStatus: ConditionStatus, _ error: String?) -> Void) {
        guard let osVersionMatch = self.osVersion else {
            completionHandler(.failed, nil)
            return
        }

        switch self.conditionMatch {
        case .equal:
            completionHandler(ProcessInfo.processInfo.operatingSystemVersion == osVersionMatch ? .pass : .failed, nil)
        case .greaterThan:
            completionHandler(ProcessInfo.processInfo.operatingSystemVersion != osVersionMatch && ProcessInfo.processInfo.isOperatingSystemAtLeast(osVersionMatch) ? .pass : .failed, nil)
        case .greaterThanOrEqual:
            completionHandler(ProcessInfo.processInfo.isOperatingSystemAtLeast(osVersionMatch) ? .pass : .failed, nil)
        case .lessThan:
            completionHandler(ProcessInfo.processInfo.operatingSystemVersion != osVersionMatch && !ProcessInfo.processInfo.isOperatingSystemAtLeast(osVersionMatch) ? .pass : .failed, nil)
        case .lessThanOrEqual:
            completionHandler(ProcessInfo.processInfo.operatingSystemVersion == osVersionMatch || !ProcessInfo.processInfo.isOperatingSystemAtLeast(osVersionMatch) ? .pass : .failed, nil)
        default:
            Swift.print("Unhandled match: \(String(describing: self.conditionMatch))")
            completionHandler(.failed, nil)
        }
    }
}
