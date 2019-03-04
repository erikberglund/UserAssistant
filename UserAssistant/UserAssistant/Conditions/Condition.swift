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

    var items = [ConditionItem]()

    // MARK: -
    // MARK: Initialization

    init?(configuration: [String: [String: Any]]) throws {

        // ---------------------------------------------------------------------
        //  Initialize non-required variables
        // ---------------------------------------------------------------------
        for (key, itemConfiguration) in configuration {
            if let conditionItem = try ConditionItem(key: key, configuration: itemConfiguration) {
                self.items.append(conditionItem)
            }
        }
    }

    // MARK: -
    // MARK: Verify Conditions

    func verify(completionHandler: @escaping (_ conditionStatus: ConditionStatus, _ conditionError: String?) -> Void) {

        let dispatchQueue = DispatchQueue(label: "verifyConditionItem")
        let dispatchGroup = DispatchGroup()
        let dispatchSemaphore = DispatchSemaphore(value: 0)

        dispatchQueue.async {
            for conditionItem in self.items {
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

                conditionItem.verify(completionHandler: completion)
                dispatchSemaphore.wait()
            }
        }

        dispatchGroup.notify(queue: dispatchQueue) {
            DispatchQueue.main.async { completionHandler(.pass, nil) }
        }
    }

    func verify(application: NSRunningApplication, completionHandler: @escaping (_ conditionStatus: ConditionStatus, _ error: String?) -> Void) {

        let dispatchQueue = DispatchQueue(label: "verifyConditionItemApplication")
        let dispatchGroup = DispatchGroup()
        let dispatchSemaphore = DispatchSemaphore(value: 0)

        dispatchQueue.async {
            for conditionItem in self.items {
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

                conditionItem.verifyApplication(application, completionHandler: completion)
                dispatchSemaphore.wait()
            }
        }

        dispatchGroup.notify(queue: dispatchQueue) {
            DispatchQueue.main.async { completionHandler(.pass, nil) }
        }
    }
}
