//
//  Conditions.swift
//  UserAssistant
//
//  Created by Erik Berglund on 2018-08-30.
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

    func verifyBaseConditions(conditionsRequire: ConditionsRequire, completionHandler: @escaping (_ conditionStatus: ConditionStatus, _ error: String?) -> Void) {
        let baseConditions = self.conditions.filter({ $0.osVersion != nil })

        guard !baseConditions.isEmpty else {
            completionHandler(.pass, nil)
            return
        }

        self.verify(baseConditions,
                    application: nil,
                    conditionsRequire: conditionsRequire,
                    completionHandler: completionHandler)
    }

    func verify(conditionsRequire: ConditionsRequire, application: NSRunningApplication?, completionHandler: @escaping (_ conditionStatus: ConditionStatus, _ error: String?) -> Void) {
        self.verify(self.conditions,
                    application: application,
                    conditionsRequire: conditionsRequire,
                    completionHandler: completionHandler)
    }

    private func verify(_ conditions: [Condition], application app: NSRunningApplication?, conditionsRequire: ConditionsRequire, completionHandler: @escaping (_ conditionStatus: ConditionStatus, _ error: String?) -> Void) {

        let dispatchQueue = DispatchQueue(label: "serial")
        let dispatchGroup = DispatchGroup()
        let dispatchSemaphore = DispatchSemaphore(value: 0)

        dispatchQueue.async {
            for condition in conditions {
                dispatchGroup.enter()
                if let application = app {
                    condition.verify(application: application) { (conditionStatus, error) in
                        if conditionStatus == .failed {
                            if conditionsRequire == .all {
                                DispatchQueue.main.async {
                                    completionHandler(conditionStatus, error)
                                }
                                return
                            }
                        } else if conditionStatus == .pass, conditionsRequire == .any {
                            DispatchQueue.main.async {
                                completionHandler(conditionStatus, nil)
                            }
                            return
                        }
                        dispatchSemaphore.signal()
                        dispatchGroup.leave()
                    }
                } else {
                    condition.verify { (conditionStatus, error) in
                        Swift.print("conditionStatus: \(conditionStatus)")
                        if conditionStatus == .failed {
                            if conditionsRequire == .all {
                                DispatchQueue.main.async {
                                    completionHandler(conditionStatus, error)
                                }
                                return
                            }
                        } else if conditionStatus == .pass, conditionsRequire == .any {
                            DispatchQueue.main.async {
                                completionHandler(conditionStatus, nil)
                            }
                            return
                        }
                        dispatchSemaphore.signal()
                        dispatchGroup.leave()
                    }
                }
                dispatchSemaphore.wait()
            }
        }

        dispatchGroup.notify(queue: dispatchQueue) {
            DispatchQueue.main.async {
                if conditionsRequire == .all {
                    completionHandler(.pass, nil)
                } else if conditionsRequire == .any {
                    completionHandler(.failed, nil)
                }
            }
        }
    }
}
