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

        Swift.print("actionKeys: \(actionKeys)")
        Swift.print("isUserLoggingIn: \(isUserLoggingIn)")

        var newActionsActive = [Action]()
        var newActionsInactive = [Action]()

        guard let keys = actionKeys else {
            Swift.print("No keys passed for registration")
            return
        }

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
                            dispatchSemaphore.signal()
                            dispatchGroup.leave()
                        } else {
                            switch action.type {
                            case .applicationBlock,
                                 .applicationWarn:
                                ActionApplication.shared.register(action: action)
                            case .message:
                                ActionMessage.shared.register(action: action)
                            }

                            Swift.print("next scheduled trigger: \(action.nextScheduledTrigger())")

                            newActionsActive.append(action)
                        }
                    })
                } catch {
                    Swift.print("Failed to create action from configuration: \(value) with error: \(error)")
                    Swift.print("Error: \(error)")
                    dispatchSemaphore.signal()
                    dispatchGroup.leave()
                }
                dispatchSemaphore.wait()
            }
        }

        dispatchGroup.notify(queue: dispatchQueue) {
            DispatchQueue.main.async {
                for action in self.actionsActive.filter({
                    let identifier = $0.identifier
                    return !newActionsActive.contains(where: { $0.identifier == identifier })
                }) {
                    Swift.print("Action to deactivate: \(action.identifier)")
                }

                if isUserLoggingIn {
                    let loginActions = self.actionsActive.filter { $0.triggers?.triggersMatching(.login).isEmpty ?? false }
                    for action in loginActions {
                        self.show(action)
                    }
                }

                self.actionsActive = newActionsActive
                self.actionsInactive = newActionsInactive
            }
        }
    }

    func queue(_ action: Action) {
        if self.window.isVisible, action.type == .applicationBlock {
            if !self.actionsQueued.contains(where: {$0.identifier == action.identifier }) {
                self.actionsQueued.insert(action, at: 0)
            }
            self.show(action)
        } else {
            if !self.actionsQueued.contains(where: {$0.identifier == action.identifier }) {
                Swift.print("Adding action: \(action.identifier) to queue")
                self.actionsQueued.append(action)
                self.showQueuedAction()
            } else if self.window.isVisible {
                self.window.orderFront()
            }
        }
    }

    func showQueuedAction() {
        guard let nextAction = self.actionsQueued.first else {
            Swift.print("No more actions.")
            return
        }

        if !self.window.isVisible {
            self.show(nextAction)
        }
    }

    private func show(_ action: Action) {
        self.window.show(forAction: action)
    }
}
