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

     Interval
     **/
    case interval = "Interval"

    /**
     **String**

     Unit for the interval
     **/
    case intervalUnit = "IntervalUnit"

    /**
     **Integer**

     Bitmask for days to run the schedule
     **/
    case days = "Days"

    /**
     **String**

     Time Start
     **/
    case timeStart = "TimeStart"

    /**
     **String**

     Time End
     **/
    case timeEnd = "TimeEnd"

}
