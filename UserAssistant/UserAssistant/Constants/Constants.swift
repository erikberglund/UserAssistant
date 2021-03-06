//
//  Constants.swift
//  UserAssistant
//
//  Created by Erik Berglund on 2018-08-06.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Foundation

let kMessageWindowHeight: CGFloat = 580.0
let kMessageWindowWidth: CGFloat = 780.0

let kActionPrefix = "com.github.erikberglund.UserAssistant"

let kMenuBarMenuItemWidht: CGFloat = 400.0
let kMenuBarMenuItemHeight: CGFloat = 50.0

enum ActionType: String {
    case applicationLaunch
    case notification
    case message
}

enum MessageType: String {
    case messageFullScreen
    case message
    case notification
}

enum TriggerType: String {
    case load
    case login
    case logout
    case repeating
}

struct MessageWindowSize {
    static var height: CGFloat = kMessageWindowHeight
    static var width: CGFloat = kMessageWindowWidth
}
