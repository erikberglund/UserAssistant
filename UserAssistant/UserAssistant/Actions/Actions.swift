//
//  Actions.swift
//  UserAssistant
//
//  Created by Erik Berglund on 2018-08-27.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Cocoa

class Actions {

    // MARK: -
    // MARK: Static Variables

    static let shared = Actions()

    // MARK: -
    // MARK: Variables

    var window = MessageWindow()

    var actionsActive = [Action]()
    var actionsInactive = [Action]()
    var actionsQueued = [Action]()

    // MARK: -
    // MARK: Initialization

    private init() {}

    // MARK: -
    // MARK: Methods

    func register(keys actionKeys: [String]?, dict: [String: Any], isUserLoggingIn: Bool) {

        guard let keys = actionKeys else { return }

        Swift.print("actionKeys: \(actionKeys)")

        var newActionsActive = [Action]()
        var newActionsInactive = [Action]()

        let dispatchQueue = DispatchQueue(label: "serial")
        let dispatchGroup = DispatchGroup()
        let dispatchSemaphore = DispatchSemaphore(value: 0)

        dispatchQueue.async {
            for key in keys {
                guard let value = dict[key] as? [String: Any] else { continue }
                
                dispatchGroup.enter()
                do {
                    guard let action = try Action(identifier: key, configuration: value) else {
                        Swift.print("Failed to create action from configuration: \(value)")
                        dispatchSemaphore.signal()
                        dispatchGroup.leave()
                        continue
                    }

                    action.shouldRegister(completionHandler: { (status) in
                        if !status {
                            Swift.print("Action is not valid on the current machine")
                            newActionsInactive.append(action)
                        } else {
                            switch action.type {
                            case .applicationLaunch:
                                ActionApplication.shared.register(action: action)
                            case .message:
                                ActionMessage.shared.register(action: action)
                            case .notification:
                                Swift.print("Not Done")
                            }
                            newActionsActive.append(action)
                        }

                        dispatchSemaphore.signal()
                        dispatchGroup.leave()
                    })
                } catch {
                    Swift.print("Failed to create action from configuration: \(value) with error: \(error)")
                    dispatchSemaphore.signal()
                    dispatchGroup.leave()
                }

                dispatchSemaphore.wait()
            }

            dispatchGroup.notify(queue: dispatchQueue) {
                DispatchQueue.main.async {

                    // UnRegister any action that got removed when updating current actions
                    for action in self.actionsActive.filter({
                        let identifier = $0.identifier
                        return !newActionsActive.contains(where: { $0.identifier == identifier })
                    }) {
                        action.unRegister()
                    }

                    // If user was logging in when registering actions was started, run all actions with the login trigger
                    if isUserLoggingIn {
                        let loginActions = self.actionsActive.filter { $0.triggers?.triggersMatching(.login).isEmpty ?? false }
                        for action in loginActions {
                            self.show(action)
                        }
                    }

                    // Update the stored actions
                    self.actionsActive = newActionsActive
                    self.actionsInactive = newActionsInactive
                }
            }
        }
    }

    func queue(_ action: Action) {
        Swift.print("Queue: \(action.type) - \(action.identifier)")
        if self.window.isVisible, action.type == .applicationLaunch {
            if !self.actionsQueued.contains(where: {$0.identifier == action.identifier }) {
                Swift.print("Queue Add: \(action.type) - \(action.identifier)")
                self.actionsQueued.insert(action, at: 0)
            }
            self.show(action)
        } else {
            if !self.actionsQueued.contains(where: {$0.identifier == action.identifier }) {
                action.verifyConditions { (conditionStatus, errorMessage) in
                    if conditionStatus == .pass {
                        Swift.print("Queue Add: \(action.type) - \(action.identifier)")
                        self.actionsQueued.append(action)
                        self.queueShowNext()
                    }
                }
            } else if self.window.isVisible {
                self.window.orderFront()
            }
        }
    }

    func queueShowNext() {
        if let action = self.actionsQueued.first {
            self.show(action)
        }
    }

    private func show(_ action: Action) {
        self.window.show(forAction: action)
    }
}
