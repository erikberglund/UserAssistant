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
    var timeStart: String?
    var timeStartMinute: Int = 0
    var timeStartHour: Int = 0
    var timeEnd: String?
    var timeEndMinute: Int = 0
    var timeEndHour: Int = 0

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

        case .timeStart:
            if let timeStart = value as? String {
                let timeStartArray = timeStart.components(separatedBy: ":")
                guard
                    timeStartArray.count == 2,
                    let timeStartHourString = timeStartArray.first,
                    let timeStartHour = Int(timeStartHourString),
                    let timeStartMinuteString = timeStartArray.last,
                    let timeStartMinute = Int(timeStartMinuteString) else {
                        return
                }
                self.timeStart = timeStart
                self.timeStartHour = timeStartHour
                self.timeStartMinute = timeStartMinute
            }

        case .timeEnd:
            if let timeEnd = value as? String {
                let timeEndArray = timeEnd.components(separatedBy: ":")
                guard
                    timeEndArray.count == 2,
                    let timeEndHourString = timeEndArray.first,
                    let timeEndHour = Int(timeEndHourString),
                    let timeEndMinuteString = timeEndArray.last,
                    let timeEndMinute = Int(timeEndMinuteString) else {
                        return
                }
                self.timeEnd = timeEnd
                self.timeEndHour = timeEndHour
                self.timeEndMinute = timeEndMinute
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
            dndStartDateComponents.hour = dndSchedule.timeStartHour
            dndStartDateComponents.minute = dndSchedule.timeStartMinute
            guard let dndStartDate = Calendar.current.date(from: dndStartDateComponents) else { return nil }

            var dndEndDateComponents = Calendar.current.dateComponents(componentFlags, from: futureDate)
            dndEndDateComponents.hour = dndSchedule.timeEndHour
            dndEndDateComponents.minute = dndSchedule.timeEndMinute
            if dndSchedule.timeEndHour < dndSchedule.timeStartHour, let componentDay = dndEndDateComponents.day {
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
