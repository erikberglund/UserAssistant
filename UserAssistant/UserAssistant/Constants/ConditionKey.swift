//
//  ConditionKey.swift
//  UserAssistant
//
//  Created by Erik Berglund on 2018-08-30.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Foundation


enum ConditionKey: String {

    /**
     **String**

     How the condition should match the values

     *Required*
     */
    case conditionMatch = "ConditionMatch"

    /**
     **String**

     Status string for Firmware Password
     - unknown
     - enabled
     - disabled
     */
    case firmwarePasswordStatus = "FirmwarePasswordStatus"

    /**
     **Array**

     An array of MDMStatusEnrollment strings
     */
    case mdmStatusEnrollment = "MDMStatusEnrollment"

    /**
     **String**

     OS version string, like 10.13.6
     */
    case osVersion = "OSVersion"

    /**
     **String**

     A script to run, that must only return
     */
    case script = "Script"

    /**
     **Bool**

     If the conditions is required.
     */
    case required = "Required"

    /**
     **String**

     The bundle identifier to match
     */
    case bundleIdentifier = "BundleIdentifier"

    /**
     **String**

     The bundle version to match
     */
    case bundleVersion = "BundleVersion"
}
