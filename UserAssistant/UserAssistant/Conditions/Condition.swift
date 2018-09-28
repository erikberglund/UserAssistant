//
//  Condition.swift
//  UserAssistant
//
//  Created by Erik Berglund on 2018-08-30.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Cocoa

class Condition {

    // MARK: -
    // MARK: Variables

    var bundleIdentifier: String?
    var bundleVersion: String?
    var conditionMatch: ConditionMatch = .equal
    var conditionKeys = [ConditionKey]()
    var mdmStatusEnrollment: [MDMStatusEnrollment]?
    var osVersion: OperatingSystemVersion?
    var script: String?

    // MARK: -
    // MARK: Initialization

    init?(configuration: [String: Any]) throws {

        // ---------------------------------------------------------------------
        //  Initialize non-required variables
        // ---------------------------------------------------------------------
        for (key, element) in configuration {
            try self.initialize(key: key, value: element)
        }
    }

    private func initialize(key: String, value: Any?) throws {
        guard let conditionKey = ConditionKey(rawValue: key) else {
            Swift.print("Unknown ActionKey will be ignored: \(key)")
            throw NSError.init(domain: "test", code: -1, userInfo: nil)
        }

        if conditionKey != .conditionMatch {
            self.conditionKeys.append(conditionKey)
        }

        switch conditionKey {
        case .conditionMatch:
            if
                let conditionMatchString = value as? String,
                let conditionMatch = ConditionMatch(rawValue: conditionMatchString) {
                self.conditionMatch = conditionMatch
            } else {
                throw NSError.init(domain: "test", code: -1, userInfo: nil)
            }

            Swift.print("Condition: [\(conditionKey)]: \(String(describing: self.conditionMatch))")

        case .mdmStatusEnrollment:
            if let mdmStatusEnrollmentArray = value as? [String] {
                var mdmStatusEnrollment = [MDMStatusEnrollment]()
                for mdmStatusEnrollmentString in mdmStatusEnrollmentArray {
                    if let enrollmentStatus = MDMStatusEnrollment(rawValue: mdmStatusEnrollmentString) {
                        mdmStatusEnrollment.append(enrollmentStatus)
                    }
                }

                guard !mdmStatusEnrollment.isEmpty else {
                    throw NSError.init(domain: "test", code: -1, userInfo: nil)
                }

                self.mdmStatusEnrollment = mdmStatusEnrollment
            }

            guard self.mdmStatusEnrollment != nil else {
                throw NSError.init(domain: "test", code: -1, userInfo: nil)
            }

            Swift.print("Condition: [\(conditionKey)]: \(String(describing: self.mdmStatusEnrollment))")

        case .osVersion:
            if
                let osVersionString = value as? String,
                let osVersion = OperatingSystemVersion(versionString: osVersionString) {
                self.osVersion = osVersion
            } else {
                throw NSError.init(domain: "test", code: -1, userInfo: nil)
            }

            guard self.conditionMatch != .contains, self.conditionMatch != .notContains else {
                throw NSError.init(domain: "Test", code: -1, userInfo: nil)
            }

            Swift.print("Condition: [\(conditionKey)]: \(String(describing: self.osVersion))")

        case .script:
            if let script = value as? String, !script.isEmpty {
                self.script = script
            } else {
                throw NSError.init(domain: "test", code: -1, userInfo: nil)
            }

            Swift.print("Condition: [\(conditionKey)]: \(String(describing: self.script))")

        case .bundleIdentifier:
            if let bundleIdentifier = value as? String {
                self.bundleIdentifier = bundleIdentifier
            } else {
                throw NSError.init(domain: "test", code: -1, userInfo: nil)
            }

            Swift.print("Condition: [\(conditionKey)]: \(String(describing: self.bundleIdentifier))")
            
        case .bundleVersion:
            if let bundleVersion = value as? String {
                self.bundleVersion = bundleVersion
            } else {
                throw NSError.init(domain: "test", code: -1, userInfo: nil)
            }

            Swift.print("Condition: [\(conditionKey)]: \(String(describing: self.bundleVersion))")
        }
    }

    // MARK: -
    // MARK: Check Conditions

    func verify(completionHandler: @escaping (_ conditionStatus: ConditionStatus, _ error: String?) -> Void) {
        for conditionKey in self.conditionKeys {

            Swift.print("Verifying condition: \(conditionKey)")

            switch conditionKey {
            case .mdmStatusEnrollment:
                self.verifyMDMStatusEnrollment(completionHandler: completionHandler)
            case .osVersion:
                self.verifyOSVersion(completionHandler: completionHandler)
            case .script:
                self.verifyScript(completionHandler: completionHandler)
            case .conditionMatch:
                Swift.print("The key: \(conditionKey) should not be included in the conditions to evaluate")
            case .bundleIdentifier:
                fatalError("Actions containing bundleIdentifier must be called using verify(application:completionHandler:)")
            case .bundleVersion:
                fatalError("Actions containing bundleVersion must be called using verify(application:completionHandler:)")
            }
        }
    }

    func verify(application: NSRunningApplication, completionHandler: @escaping (_ conditionStatus: ConditionStatus, _ error: String?) -> Void) {
        for conditionKey in self.conditionKeys {

            Swift.print("Verifying condition: \(conditionKey) for application: \(application)")

            switch conditionKey {
                case .mdmStatusEnrollment,
                     .osVersion,
                     .script,
                     .conditionMatch:
                self.verify(completionHandler: completionHandler)
            case .bundleIdentifier,
                 .bundleVersion:
                self.verifyApplication(application, completionHandler: completionHandler)
            }
        }
    }
}
