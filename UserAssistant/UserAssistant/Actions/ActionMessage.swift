//
//  ActionMessage.swift
//  UserAssistant
//
//  Created by Erik Berglund on 2018-09-13.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Foundation

class ActionMessage {

    // MARK: -
    // MARK: Static Variables

    static let shared = ActionMessage()

    // MARK: -
    // MARK: Private Variables

    private var actions = Set<Action>()
    private var timers = Set<Timer>()

    // MARK: -
    // MARK: Initialization

    private init() {}

    // MARK: -
    // MARK: Registration

    func register(action: Action) {
        if !self.actions.contains(action) {
            Swift.print("Registering: \(action.identifier)")
            self.actions.insert(action)
            self.scheduleAction(action)
        }
    }

    func scheduleAction(_ action: Action) {
        if let nextTrigger = action.nextScheduledTrigger() {
            Swift.print("nextTrigger: \(nextTrigger)")
            let timer = Timer.scheduledTimer(timeInterval: nextTrigger.timeIntervalSince(Date()),
                                             target: self,
                                             selector: #selector(self.queueAction(_:)),
                                             userInfo: ["identifier": action.identifier],
                                             repeats: false)
            self.timers.insert(timer)
        } else {
            Swift.print("Failed to get next trigger...")
        }
    }

    @objc private func queueAction(_ timer: Timer) {
        let timerUserInfo = timer.userInfo as? [String: Any]
        timer.invalidate()
        self.timers.remove(timer)

        guard
            let userInfo = timerUserInfo,
            let identifier = userInfo["identifier"] as? String,
            let action = self.actions.first(where: { $0.identifier == identifier }) else {
                return
        }

        self.scheduleAction(action)
        Actions.shared.queue(action)
    }
}
