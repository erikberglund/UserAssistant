//
//  MessageWindowType.swift
//  UserAssistant
//
//  Created by Erik Berglund on 2018-08-06.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Foundation

enum MessageWindowType {

    /**
     A window that requires user action.
     */
    case action

    /**
     A window that requires user action (full screen).
     */
    case actionFullScreen

    /**
     A window shown on application launch (full screen).
     */
    case applicationFullScreen

    /**
     A window that only displays information without requiring user action.
     */
    case info

    /**
     A window that only displays information without requiring user action (full screen).
     */
    case infoFullScreen
}
