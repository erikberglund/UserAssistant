//
//  ConditionApplication.swift
//  UserAssistant
//
//  Created by Erik Berglund on 2018-09-13.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Cocoa

extension Condition {
    func verifyApplication(_ application: NSRunningApplication, completionHandler: @escaping (_ conditionStatus: ConditionStatus, _ error: String?) -> Void) {

        Swift.print("application.bundleURL: \(application.bundleURL)")

        var conditionStatus: ConditionStatus = .failed

        if let bundleIdentifier = self.bundleIdentifier {
            guard let appBundleIdentifier = application.bundleIdentifier else {
                completionHandler(.failed, nil)
                return
            }

            switch self.conditionMatch {

            case .equal:
                conditionStatus = appBundleIdentifier == bundleIdentifier ? .pass : .failed
            case .notEqual:
                conditionStatus = appBundleIdentifier != bundleIdentifier ? .pass : .failed
            case .contains:
                conditionStatus = appBundleIdentifier.contains(bundleIdentifier) ? .pass : .failed
            case .notContains:
                conditionStatus = !appBundleIdentifier.contains(bundleIdentifier) ? .pass : .failed
            case .beginsWith:
                conditionStatus = appBundleIdentifier.hasPrefix(bundleIdentifier) ? .pass : .failed
            case .endsWith:
                conditionStatus = appBundleIdentifier.hasSuffix(bundleIdentifier) ? .pass : .failed
            case .greaterThan,
                 .greaterThanOrEqual,
                 .lessThan,
                 .lessThanOrEqual:
                Swift.print("Invalid condition match: \(self.conditionMatch)")
                conditionStatus = .failed
            }

            if conditionStatus == .failed {
                Swift.print("Condition \"\(self.conditionMatch)\" did not match when comparing application bundle identifier: \(appBundleIdentifier) to: \(bundleIdentifier)")
                completionHandler(conditionStatus, nil)
                return
            }
        }

        if let bundleVersion = self.bundleVersion {
            guard let appBundleVersion = application.infoDictionary?["CFBundleShortVersionString"] as? String else {
                    completionHandler(.failed, nil)
                    return
            }

            switch self.conditionMatch {

            case .equal:
                conditionStatus = appBundleVersion == bundleVersion ? .pass : .failed
            case .notEqual:
                conditionStatus = appBundleVersion != bundleVersion ? .pass : .failed
            case .contains:
                conditionStatus = appBundleVersion.contains(bundleVersion) ? .pass : .failed
            case .notContains:
                conditionStatus = !appBundleVersion.contains(bundleVersion) ? .pass : .failed
            case .beginsWith:
                conditionStatus = appBundleVersion.hasPrefix(bundleVersion) ? .pass : .failed
            case .endsWith:
                conditionStatus = appBundleVersion.hasSuffix(bundleVersion) ? .pass : .failed
            case .greaterThan:
                conditionStatus = appBundleVersion.isVersion(greaterThan: bundleVersion) ? .pass : .failed
            case .greaterThanOrEqual:
                conditionStatus = appBundleVersion.isVersion(greaterThanOrEqualTo: bundleVersion) ? .pass : .failed
            case .lessThan:
                conditionStatus = appBundleVersion.isVersion(lessThan: bundleVersion) ? .pass : .failed
            case .lessThanOrEqual:
                conditionStatus = appBundleVersion.isVersion(lessThanOrEqualTo: bundleVersion) ? .pass : .failed
            }

            if conditionStatus == .failed {
                Swift.print("Condition \"\(self.conditionMatch)\" did not match when comparing application bundle version: \(appBundleVersion) to: \(bundleVersion)")
                completionHandler(conditionStatus, nil)
                return
            }
        }

        completionHandler(conditionStatus, nil)
    }
}
