//
//  HelperProtocol.swift
//  com.github.erikberglund.UserAssistantHelper
//
//  Created by Erik Berglund.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Foundation

@objc(HelperProtocol)
protocol HelperProtocol {
    func getVersion(completion: @escaping (String) -> Void)

    // Handle AdminGroup Membership
    func groupAdminAdd(_ userName: String, authData: NSData?, completion: @escaping (NSNumber) -> Void)
    func groupAdminRemove(_ username: String, completion: @escaping (NSError) -> Void)

    // Check FirmwarePassword Status
    func firmwarePasswordCheck(completion: @escaping (_ enabled: String?, _ error: String?) -> Void)
}
