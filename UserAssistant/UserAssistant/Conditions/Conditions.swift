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

    init?(configuration: [[String: [String: Any]]]) throws {
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

        let dispatchQueue = DispatchQueue(label: "verifyConditions")
        let dispatchGroup = DispatchGroup()
        let dispatchSemaphore = DispatchSemaphore(value: 0)

        dispatchQueue.async {
            for condition in conditions {
                dispatchGroup.enter()

                let completion: (ConditionStatus, String?) -> Void = { (conditionStatus, error) in
                    if conditionStatus == .failed {
                        DispatchQueue.main.async { completionHandler(conditionStatus, error) }
                        dispatchGroup.leave()
                        return
                    }

                    dispatchSemaphore.signal()
                    dispatchGroup.leave()
                }

                // Call verify depending on if an app was passed or not
                if let application = app {
                    condition.verify(application: application, completionHandler: completion)
                } else {
                    condition.verify(completionHandler: completion)
                }

                dispatchSemaphore.wait()
            }
        }

        dispatchGroup.notify(queue: dispatchQueue) {
            DispatchQueue.main.async { completionHandler(.pass, nil) }
        }
    }
}
