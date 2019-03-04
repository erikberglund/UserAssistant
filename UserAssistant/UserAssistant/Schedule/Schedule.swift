//
//  Schedule.swift
//  UserAssistant
//
//  Created by Erik Berglund on 2018-09-17.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Foundation

class Schedule {

    // MARK: -
    // MARK: Variables

    var days: ScheduleDays = .all
    var interval: Int?
    var intervalDateComponents: DateComponents?
    var intervalUnit: ScheduleInterval?
    var notValidBeforeTime: String?
    var notValidBeforeTimeMinute: Int = 0
    var notValidBeforeTimeHour: Int = 0
    var notValidAfterTime: String?
    var notValidAfterTimeMinute: Int = 0
    var notValidAfterTimeHour: Int = 0

    // MARK: -
    // MARK: Initialization

    init?(_ schedule: [String: Any]) throws {

        // ---------------------------------------------------------------------
        //  Initialize non-required variables
        // ---------------------------------------------------------------------
        for (key, element) in schedule {
            try self.initialize(key: key, value: element)
        }

        if let interval = self.interval, let intervalUnit = self.intervalUnit {
            var dateComponents = DateComponents()
            switch intervalUnit {
            case .month:
                dateComponents.month = interval
            case .week:
                dateComponents.weekOfMonth = interval
            case .day:
                dateComponents.day = interval
            case .hour:
                dateComponents.hour = interval
            case .minute:
                dateComponents.minute = interval
            }
            self.intervalDateComponents = dateComponents
        }
    }

    private func initialize(key: String, value: Any?) throws {
        guard let scheduleKey = ScheduleKey(rawValue: key) else {
            Swift.print("Unknown ScheduleKey will be ignored: \(key)")
            throw NSError.init(domain: "test", code: -1, userInfo: nil)
        }

        switch scheduleKey {
        case .days:
            if let daysInt = value as? Int {
                self.days = ScheduleDays(rawValue: daysInt)
            }

        case .interval:
            if let interval = value as? Int {
                self.interval = interval
            }

        case .intervalUnit:
            if let intervalUnitString = value as? String, let intervalUnit = ScheduleInterval(rawValue: intervalUnitString.lowercased()) {
                self.intervalUnit = intervalUnit
            }

        case .notValidBeforeTime:
            if
                let notValidBeforeTime = value as? String {
                let notValidBeforeTimeArray = notValidBeforeTime.components(separatedBy: ":")
                guard
                    notValidBeforeTimeArray.count == 2,
                    let notValidBeforeTimeHourString = notValidBeforeTimeArray.first,
                    let notValidBeforeTimeHour = Int(notValidBeforeTimeHourString),
                    let notValidBeforeTimeMinuteString = notValidBeforeTimeArray.last,
                    let notValidBeforeTimeMinute = Int(notValidBeforeTimeMinuteString) else {
                        return
                }
                self.notValidBeforeTime = notValidBeforeTime
                self.notValidBeforeTimeHour = notValidBeforeTimeHour
                self.notValidBeforeTimeMinute = notValidBeforeTimeMinute
            }

        case .notValidAfterTime:
            if
                let notValidAfterTime = value as? String {
                let notValidAfterTimeArray = notValidAfterTime.components(separatedBy: ":")
                guard
                    notValidAfterTimeArray.count == 2,
                    let notValidAfterTimeHourString = notValidAfterTimeArray.first,
                    let notValidAfterTimeHour = Int(notValidAfterTimeHourString),
                    let notValidAfterTimeMinuteString = notValidAfterTimeArray.last,
                    let notValidAfterTimeMinute = Int(notValidAfterTimeMinuteString) else {
                        return
                }
                self.notValidAfterTime = notValidAfterTime
                self.notValidAfterTimeHour = notValidAfterTimeHour
                self.notValidAfterTimeMinute = notValidAfterTimeMinute
            }
        }
    }

    func nextScheduledTrigger(dndSchedule: Schedule?) -> Date? {

        if
            let interval = self.interval,
            let intervalUnit = self.intervalUnit {
            return self.nextScheduledTrigger(after: Date(), interval: interval, intervalUnit: intervalUnit, dndSchedule: dndSchedule)
        }

        return nil
    }

    func nextScheduledTrigger(after date: Date, interval: Int, intervalUnit: ScheduleInterval, dndSchedule dnd: Schedule?) -> Date? {

        guard let intervalDateComponents = self.intervalDateComponents else {
            return nil
        }

        guard let futureDate = Calendar.current.date(byAdding: intervalDateComponents, to: date) else {
            return nil
        }

        let componentFlags = Set<Calendar.Component>([.year, .month, .day, .hour, .minute, .second])

        if let dndSchedule = dnd {

            var dndStartDateComponents = Calendar.current.dateComponents(componentFlags, from: futureDate)
            dndStartDateComponents.hour = dndSchedule.notValidBeforeTimeHour
            dndStartDateComponents.minute = dndSchedule.notValidBeforeTimeMinute
            guard let dndStartDate = Calendar.current.date(from: dndStartDateComponents) else { return nil }

            var dndEndDateComponents = Calendar.current.dateComponents(componentFlags, from: futureDate)
            dndEndDateComponents.hour = dndSchedule.notValidAfterTimeHour
            dndEndDateComponents.minute = dndSchedule.notValidAfterTimeMinute
            if dndSchedule.notValidAfterTimeHour < dndSchedule.notValidBeforeTimeHour, let componentDay = dndEndDateComponents.day {
                dndEndDateComponents.day = componentDay + 1
            }
            guard let dndEndDate = Calendar.current.date(from: dndEndDateComponents) else { return nil }

            if
                (dndStartDate < dndEndDate && dndStartDate < futureDate && futureDate < dndEndDate) ||
                (dndStartDate > dndEndDate && dndStartDate > futureDate && futureDate > dndEndDate) {
                Swift.print("Returning DND Date: \(dndEndDate)")
                return dndEndDate
            }
        }

        var nextDateComponents = Calendar.current.dateComponents(componentFlags, from: futureDate)
        switch intervalUnit {
        case .month:
            nextDateComponents.weekOfMonth = 1
            nextDateComponents.day = 1
            nextDateComponents.hour = 9
            nextDateComponents.minute = 0
        case .week:
            nextDateComponents.day = 1
            nextDateComponents.hour = 9
            nextDateComponents.minute = 0
        case .day:
            nextDateComponents.hour = 9
            nextDateComponents.minute = 0
        case .hour:
            nextDateComponents.minute = 0
        case .minute:
            break
        }
        nextDateComponents.second = 0

        // Return the next date
        return Calendar.current.nextDate(after: date, matching: nextDateComponents, matchingPolicy: .nextTime, repeatedTimePolicy: .first, direction: .forward)
    }
}
