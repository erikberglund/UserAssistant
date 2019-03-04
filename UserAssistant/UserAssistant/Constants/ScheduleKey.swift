//
//  ScheduleKey.swift
//  UserAssistant
//
//  Created by Erik Berglund on 2018-09-17.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Foundation

enum ScheduleKey: String {

    /**
     **Integer**

     Value for the interval.
     **/
    case interval = "Interval"

    /**
     **String**

     Unit for the interval.
     **/
    case intervalUnit = "IntervalUnit"

    /**
     **Integer**

     Bitmask of weekdays to run the schedule.
     **/
    case days = "Days"

    /**
     **String**

     Time Start
     **/
    case notValidBeforeTime = "NotValidBeforeTime"

    /**
     **String**

     Time End
     **/
    case notValidAfterTime = "NotValidAfterTime"

}
