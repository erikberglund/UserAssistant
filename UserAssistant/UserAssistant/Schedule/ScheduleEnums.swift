//
//  ScheduleEnums.swift
//  UserAssistant
//
//  Created by Erik Berglund on 2018-09-17.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Foundation

struct ScheduleDays: OptionSet {

    let rawValue: Int

    static let monday       = ScheduleDays(rawValue: 1 << 0)
    static let tuesday      = ScheduleDays(rawValue: 1 << 1)
    static let wednesday    = ScheduleDays(rawValue: 1 << 2)
    static let thursday     = ScheduleDays(rawValue: 1 << 3)
    static let friday       = ScheduleDays(rawValue: 1 << 4)
    static let saturday     = ScheduleDays(rawValue: 1 << 5)
    static let sunday       = ScheduleDays(rawValue: 1 << 6)

    static let all: ScheduleDays        = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
    static let weekend: ScheduleDays    = [.saturday, .sunday]
    static let weekdays: ScheduleDays   = [.monday, .tuesday, .wednesday, .thursday, .friday]

}

enum ScheduleInterval: String {
    case minute
    case hour
    case day
    case week
    case month
}
