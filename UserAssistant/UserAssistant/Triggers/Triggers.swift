//
//  Triggers.swift
//  UserAssistant
//
//  Created by Erik Berglund on 2018-09-17.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Foundation

class Triggers {

    // MARK: -
    // MARK: Variables

    private var triggers = [Trigger]()

    // MARK: -
    // MARK: Initialization

    init?(_ triggerArray: [[String: Any]]) throws {

        for triggerDict in triggerArray {
            guard let trigger = try Trigger(triggerDict) else {
                continue
            }
            triggers.append(trigger)
        }
    }

    func nextScheduledTrigger(dndSchedule: Schedule?) -> Date? {
        var nextDate: Date?
        for trigger in self.triggers {
            if let triggerDate = trigger.nextScheduledTrigger(dndSchedule: dndSchedule) {
                if nextDate == nil {
                    nextDate = triggerDate
                } else if let date = nextDate, triggerDate < date {
                    nextDate = triggerDate
                }
            }
        }
        return nextDate
    }

    func triggersMatching(_ type: TriggerType) -> [Trigger] {
        return self.triggers.filter { $0.type == type }
    }
}
