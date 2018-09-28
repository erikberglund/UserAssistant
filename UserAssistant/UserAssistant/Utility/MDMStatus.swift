//
//  MDMStatus.swift
//  UserAssistant
//
//  Created by Erik Berglund on 2018-08-29.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Foundation

enum MDMStatusEnrollment: String {
    case unknown
    case notEnrolled
    case enrolled
    case enrolledDEP
    case enrolledUserApproved

    init(statusString: String) {
        if statusString.contains("User Approved") {
            self = .enrolledUserApproved
        } else if statusString.contains("Yes") {
            self = .enrolled
        } else if statusString.contains("No") {
            self = .notEnrolled
        } else {
            self = .unknown
        }
    }
}

class MDMStatus {

    class func enrollment(completionHandler: @escaping (_ mdmStatusEnrollment: MDMStatusEnrollment, _ error: String?) -> Void) {
        runTask(command: "/usr/bin/profiles", arguments: ["status", "-type", "enrollment"]) { (stdOut, stdErr, exitCode) in

            guard exitCode == 0, let status = stdOut else {
                completionHandler(.unknown, stdErr);
                return
            }

            var mdmStatus: MDMStatusEnrollment = .unknown

            for line in status.components(separatedBy: "\n") {
                if line.hasPrefix("Enrolled via DEP"), line.hasSuffix("Yes") {
                    mdmStatus = .enrolledDEP
                } else if line.hasPrefix("MDM enrollment"), let statusString = line.components(separatedBy: ":").last {
                    mdmStatus = MDMStatusEnrollment(statusString: statusString)
                }
            }

            completionHandler(mdmStatus, nil)
        }
    }
}
