//
//  ConditionMDMStatusEnrollment.swift
//  UserAssistant
//
//  Created by Erik Berglund on 2018-08-30.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Foundation

extension ConditionItem {
    func verifyMDMStatusEnrollment(completionHandler: @escaping (_ conditionStatus: ConditionStatus, _ error: String?) -> Void) {
        guard let mdmStatusEnrollmentMatch = self.mdmStatusEnrollment else {
                completionHandler(.failed, nil)
                return
        }

        MDMStatus.enrollment { (mdmStatusEnrollment, error) in
            Swift.print("mdmStatusEnrollment: \(mdmStatusEnrollment)")
            Swift.print("mdmStatusEnrollmentError: \(String(describing: error))")

            switch self.conditionMatch {
            case .equal:
                completionHandler(mdmStatusEnrollmentMatch.contains(mdmStatusEnrollment) ? .pass : .failed, nil)
            case .notEqual:
                completionHandler(!mdmStatusEnrollmentMatch.contains(mdmStatusEnrollment) ? .pass : .failed, nil)
            default:
                Swift.print("Not Handled: \(String(describing: self.conditionMatch))")
                completionHandler(.failed, nil)
            }
        }
    }
}
