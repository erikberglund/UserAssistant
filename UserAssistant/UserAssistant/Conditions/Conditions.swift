//
//  Conditions.swift
//  UserAssistant
//
//  Created by Erik Berglund.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Cocoa

class Conditions {

    // MARK: -
    // MARK: Variables

    private var conditions = [Condition]()

    // MARK: -
    // MARK: Initialization

    init?(configuration: [[String: Any]]) throws {
        for conditionConfiguration in configuration {
            if let condition = try Condition(configuration: conditionConfiguration) {
                self.conditions.append(condition)
            }
        }
        
        if conditions.isEmpty {
            return nil
        }
    }

    // MARK: -
    // MARK: Verification

    func verifyAll(completionHandler: @escaping (_ conditionStatus: ConditionStatus, _ error: String?) -> Void) {
        self.verify(self.conditions, application: nil, completionHandler: completionHandler)
    }

    func verify(application: NSRunningApplication?, completionHandler: @escaping (_ conditionStatus: ConditionStatus, _ error: String?) -> Void) {
        self.verify(self.conditions, application: application, completionHandler: completionHandler)
    }

    private func verify(_ conditions: [Condition], application app: NSRunningApplication?, completionHandler: @escaping (_ conditionStatus: ConditionStatus, _ error: String?) -> Void) {

        let dispatchQueue = DispatchQueue(label: "serial")
        let dispatchGroup = DispatchGroup()
        let dispatchSemaphore = DispatchSemaphore(value: 0)

        dispatchQueue.async {

            // Loop through all condtions, beginning with the required
            for condition in conditions.sorted(by: { $0.isRequired && !$1.isRequired }) {
                dispatchGroup.enter()

                // Create a completion handler
                let completionHandler: (ConditionStatus, String?) -> Void = { (conditionStatus, error) in
                    if conditionStatus == .failed, condition.isRequired {
                        DispatchQueue.main.async {
                            completionHandler(conditionStatus, error)
                        }
                        return
                    } else if conditionStatus == .pass, !condition.isRequired {
                        DispatchQueue.main.async {
                            completionHandler(conditionStatus, nil)
                        }
                        return
                    }
                    dispatchSemaphore.signal()
                    dispatchGroup.leave()
                }

                // Call verify depending on 
                if let application = app {
                    condition.verify(application: application, completionHandler: completionHandler)
                } else {
                    condition.verify(completionHandler: completionHandler)
                }
                dispatchSemaphore.wait()
            }
        }

        dispatchGroup.notify(queue: dispatchQueue) {
            DispatchQueue.main.async {
                if conditions.contains(where: { !$0.isRequired }) {
                    completionHandler(.failed, nil)
                } else {
                    completionHandler(.pass, nil)
                }
            }
        }
    }
}
