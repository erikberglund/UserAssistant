//
//  ExtensionNotification.swift
//  UserAssistant
//
//  Created by Erik Berglund on 2018-10-03.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let MCXManagementStatusChangedForDomains = Notification.Name("com.apple.MCX._managementStatusChangedForDomains")
    static let ManagedConfigurationProfileListChanged = Notification.Name("com.apple.ManagedConfiguration.profileListChanged")
}
