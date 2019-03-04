//
//  ConditionFirmwarePassword.swift
//  UserAssistant
//
//  Created by Erik Berglund on 2018-10-16.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Foundation

extension ConditionItem {
    func verifyFirmwarePasswordStatus(completionHandler: @escaping (_ conditionStatus: ConditionStatus, _ error: String?) -> Void) {
        guard let firmwarePasswordStatusMatch = self.firmwarePasswordStatus else {
            completionHandler(.failed, nil)
            return
        }

        FirmwarePasswordStatus.check { (firmwarePasswordStatus, error) in
            Swift.print("firmwarePasswordStatusMatch: \(firmwarePasswordStatusMatch)")
            Swift.print("firmwarePasswordStatus: \(firmwarePasswordStatus)")
            Swift.print("firmwarePasswordStatusError: \(String(describing: error))")

            switch self.conditionMatch {
            case .equal:
                completionHandler(firmwarePasswordStatusMatch == firmwarePasswordStatus ? .pass : .failed, nil)
            case .notEqual:
                completionHandler(firmwarePasswordStatusMatch != firmwarePasswordStatus ? .pass : .failed, nil)
            default:
                Swift.print("Not Handled: \(String(describing: self.conditionMatch))")
                completionHandler(.failed, nil)
            }
        }
    }
}
