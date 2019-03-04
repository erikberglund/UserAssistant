//
//  PreferenceKeys.swift
//  UserAssistant
//
//  Created by Erik Berglund on 2018-08-06.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Foundation

struct PreferenceKey {

    /**
     **Bool**

     If the contact message and methods should be hidden.
     */
    static let contactHidden = "ContactHidden"

    /**
     **String**

     The contact message to display at the bottom of the message window.
     */
    static let contactMessage = "ContactMessage"

    /**
     **Array**

     The contact methods to list below the contact message at the bottom of the message window.
     */
    static let contactMethods = "ContactMethods"

    /**
     **String**

     The full path to an image file to be used as the logo (minimum 65 x 65 pixels).
     */
    static let logoPath = "LogoPath"

    /**
     **Bool**

     Determines whether the menu bar icon should be added to the system menu bar.
     */
    static let showMenuBarIcon = "ShowMenuBarIcon"

    /**
     **Float**

     Height in pixels of the message window. (Minimum: x. Default: x).
     */
    static let windowHeight = "WindowHeight"

    /**
     **Float**

     Width in pixels of the message window. (Minimum: x. Default: x).
     */
    static let windowWidth = "WindowWidth"

    /**
     **Bool**

     Whether the header view should use the default window background color.
     */
    static let windowShowHeaderBackgroundColor = "WindowShowHeaderBackgroundColor"
}
