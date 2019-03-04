//
//  BlockApplication.swift
//  UserAssistant
//
//  Created by Erik Berglund on 2018-09-13.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Cocoa

class ActionApplication {

    // MARK: -
    // MARK: Static Variables

    static let shared = ActionApplication()

    // MARK: -
    // MARK: Variables

    var isRegisteredForLaunchNotifications = false

    // MARK: -
    // MARK: Private Variables

    private var actions = Set<Action>()

    // MARK: -
    // MARK: Initialization

    private init() {}

    // MARK: -
    // MARK: Registration

    func register(action: Action) {
        Swift.print("Registering: \(action.type) - \(action.identifier)")

        if !self.isRegisteredForLaunchNotifications {
            NSWorkspace.shared.notificationCenter.addObserver(self,
                                                          selector: #selector(willLaunchApplication(_:)),
                                                          name: NSWorkspace.willLaunchApplicationNotification,
                                                          object: nil)
            self.isRegisteredForLaunchNotifications = true
        }

        if !self.actions.contains(action) {
            self.actions.insert(action)
        } else {
            self.actions.update(with: action)
        }
    }

    func unRegister(action: Action) {
        actions.remove(action)
        if actions.isEmpty {
            NSWorkspace.shared.notificationCenter.removeObserver(self,
                                                                 name: NSWorkspace.willLaunchApplicationNotification,
                                                                 object: nil)
            self.isRegisteredForLaunchNotifications = false
        }
    }

    func unRegisterAll() {
        actions.removeAll()
        NSWorkspace.shared.notificationCenter.removeObserver(self,
                                                             name: NSWorkspace.willLaunchApplicationNotification,
                                                             object: nil)
        self.isRegisteredForLaunchNotifications = false
    }

    // MARK: -
    // MARK:

    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }

    @objc func willLaunchApplication(_ notification: NSNotification) {
        
        // Get the application userInfo dictionary and an NSRunningApplication instance of the running application
        guard
            let userInfo = notification.userInfo,
            let application = userInfo[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication else {
                return
        }

        Swift.print("willLaunchApplication: \(application.bundleDisplayName)")

        for action in self.actions {
            action.verifyConditions(application) { (conditionStatus, errorMessage) in
                Swift.print("conditionStatus: \(conditionStatus)")
                if conditionStatus == .pass {
                    Swift.print("Passed")

                    Swift.print("action.applicationQuit: \(action.applicationQuit)")

                    if action.applicationQuit {
                        self.terminate(application: application)
                    }

                    if !action.applications.contains(where: { $0.bundleIdentifier == application.bundleIdentifier }) {
                        action.applications.insert(application, at: 0)
                    }

                    Actions.shared.queue(action)
                }
            }
        }
    }

    func terminate(application: NSRunningApplication) {
        Swift.print("terminate: \(application)")
        application.forceTerminate()

        Swift.print("isTerminated: \(application.isTerminated)")
        if !application.isTerminated {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
                self.terminate(application: application)
            }
        }
    }
}
