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
    var firmwarePasswordStatus: FirmwarePasswordStatusEnabled?
    var osVersion: OperatingSystemVersion?
    var script: String?
    var isRequired: Bool = false

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
            throw ConditionError.invalidKey(key)
        }

        if ![ConditionKey.conditionMatch, ConditionKey.required].contains(conditionKey) {
            self.conditionKeys.append(conditionKey)
        }

        switch conditionKey {
        case .conditionMatch:
            if
                let conditionMatchString = value as? String,
                let conditionMatch = ConditionMatch(rawValue: conditionMatchString) {
                self.conditionMatch = conditionMatch
                Swift.print("Condition: [\(conditionKey)]: \(String(describing: conditionMatch))")
            } else {
                throw ConditionError.invalidValue(value, key)
            }

        case .firmwarePasswordStatus:
            if let firmwarePasswordStatusString = value as? String,
                let firmwarePasswordStatus = FirmwarePasswordStatusEnabled(rawValue: firmwarePasswordStatusString) {
                self.firmwarePasswordStatus = firmwarePasswordStatus
                Swift.print("Condition: [\(conditionKey)]: \(String(describing: firmwarePasswordStatus))")
            } else {
                throw ConditionError.invalidValue(value, key)
            }

        case .mdmStatusEnrollment:
            if let mdmStatusEnrollmentArray = value as? [String] {
                var mdmStatusEnrollment = [MDMStatusEnrollment]()
                for mdmStatusEnrollmentString in mdmStatusEnrollmentArray {
                    if let enrollmentStatus = MDMStatusEnrollment(rawValue: mdmStatusEnrollmentString) {
                        mdmStatusEnrollment.append(enrollmentStatus)
                    }
                }

                guard !mdmStatusEnrollment.isEmpty else {
                    throw ConditionError.invalidValue(value, key)
                }

                self.mdmStatusEnrollment = mdmStatusEnrollment
                Swift.print("Condition: [\(conditionKey)]: \(String(describing: mdmStatusEnrollment))")
            } else {
                throw ConditionError.invalidValue(value, key)
            }

        case .osVersion:
            if
                let osVersionString = value as? String,
                let osVersion = OperatingSystemVersion(versionString: osVersionString) {
                self.osVersion = osVersion
                Swift.print("Condition: [\(conditionKey)]: \(String(describing: osVersion))")
            } else {
                throw ConditionError.invalidValue(value, key)
            }

            // FIXME: Need to expand this check for all keys, and create a reference
            guard self.conditionMatch != .contains, self.conditionMatch != .notContains else {
                throw ConditionError.invalidMatch(self.conditionMatch, key)
            }

        case .required:
            if let isRequired = value as? Bool {
                self.isRequired = isRequired
                Swift.print("Condition: [\(conditionKey)]: \(String(describing: isRequired))")
            } else {
                throw ConditionError.invalidValue(value, key)
            }

        case .script:
            if let script = value as? String, !script.isEmpty {
                self.script = script
                Swift.print("Condition: [\(conditionKey)]: \(String(describing: script))")
            } else {
                throw ConditionError.invalidValue(value, key)
            }

        case .bundleIdentifier:
            if let bundleIdentifier = value as? String {
                self.bundleIdentifier = bundleIdentifier
                Swift.print("Condition: [\(conditionKey)]: \(String(describing: bundleIdentifier))")
            } else {
                throw ConditionError.invalidValue(value, key)
            }
            
        case .bundleVersion:
            if let bundleVersion = value as? String {
                self.bundleVersion = bundleVersion
                Swift.print("Condition: [\(conditionKey)]: \(String(describing: bundleVersion))")
            } else {
                throw ConditionError.invalidValue(value, key)
            }
        }
    }

    // MARK: -
    // MARK: Verify Conditions

    func verify(completionHandler: @escaping (_ conditionStatus: ConditionStatus, _ error: String?) -> Void) {
        for conditionKey in self.conditionKeys {

            Swift.print("Verifying condition: \(conditionKey)")

            switch conditionKey {
            case .firmwarePasswordStatus:
                self.verifyFirmwarePasswordStatus(completionHandler: completionHandler)
            case .mdmStatusEnrollment:
                self.verifyMDMStatusEnrollment(completionHandler: completionHandler)
            case .osVersion:
                self.verifyOSVersion(completionHandler: completionHandler)
            case .script:
                self.verifyScript(completionHandler: completionHandler)
            case .required,
                 .conditionMatch:
                completionHandler(.failed, "The key: \(conditionKey) should not be included in the conditions to evaluate")
            case .bundleIdentifier:
                completionHandler(.failed, "Actions containing bundleIdentifier must be called using verify(application:completionHandler:)")
            case .bundleVersion:
                completionHandler(.failed, "Actions containing bundleVersion must be called using verify(application:completionHandler:)")
            }
        }
    }

    func verify(application: NSRunningApplication, completionHandler: @escaping (_ conditionStatus: ConditionStatus, _ error: String?) -> Void) {
        for conditionKey in self.conditionKeys {

            Swift.print("Verifying condition: \(conditionKey) for application: \(application)")

            switch conditionKey {
            case .bundleIdentifier,
                 .bundleVersion:
                self.verifyApplication(application, completionHandler: completionHandler)
            default:
                self.verify(completionHandler: completionHandler)
            }
        }
    }
}
