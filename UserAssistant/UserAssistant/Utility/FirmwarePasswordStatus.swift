//
//  FirmwarePasswordStatus.swift
//  UserAssistant
//
//  Created by Erik Berglund on 2018-10-16.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Foundation

enum FirmwarePasswordStatusEnabled: String {
    case unknown
    case enabled
    case disabled

    init(statusString: String) {
        if statusString.contains("Yes") {
            self = .enabled
        } else if statusString.contains("No") {
            self = .disabled
        } else {
            self = .unknown
        }
    }
}

class FirmwarePasswordStatus {
    class func check(completionHandler: @escaping (_ firmwarePasswordStatus: FirmwarePasswordStatusEnabled, _ error: String?) -> Void) {
        guard let helper = HelperConnection.shared.helper(nil) else {
            completionHandler(.unknown, "Failed to connect to the helper")
            return
        }

        helper.firmwarePasswordCheck { (statusString, errorString) in
            if let status = statusString {
                completionHandler(FirmwarePasswordStatusEnabled(statusString: status), errorString)
            } else {
                completionHandler(.unknown, errorString)
            }
        }
    }
}
