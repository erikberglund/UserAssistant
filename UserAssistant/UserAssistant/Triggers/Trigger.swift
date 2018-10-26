//
//  Trigger.swift
//  UserAssistant
//
//  Created by Erik Berglund on 2018-09-17.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Foundation

class Trigger {

    // MARK: -
    // MARK: Required Variables

    let type: TriggerType

    // MARK: -
    // MARK: Variables

    var schedule: Schedule?

    // MARK: -
    // MARK: Initialization

    init?(_ triggerDict: [String: Any]) throws {

        guard
            let triggerTypeString = triggerDict[TriggerKey.type.rawValue] as? String,
            let triggerType = TriggerType(rawValue: triggerTypeString) else {
            throw NSError.init(domain: "test", code: -1, userInfo: nil)
        }
        self.type = triggerType

        // ---------------------------------------------------------------------
        //  Initialize non-required variables
        // ---------------------------------------------------------------------
        for (key, element) in triggerDict {
            try self.initialize(key: key, value: element)
        }
    }

    private func initialize(key: String, value: Any?) throws {
        guard let triggerKey = TriggerKey(rawValue: key) else {
            Swift.print("Unknown TriggerKey will be ignored: \(key)")
            throw NSError.init(domain: "test", code: -1, userInfo: nil)
        }

        switch triggerKey {
        case .schedule:
            if let schedule = value as? [String: Any] {
                self.schedule = try Schedule(schedule)
            }

        case .type:
            return
        }
    }

    func nextScheduledTrigger(dndSchedule: Schedule?) -> Date? {
        guard self.type == .repeating else {
            return nil
        }

        return self.schedule?.nextScheduledTrigger(dndSchedule: dndSchedule)
    }
}
