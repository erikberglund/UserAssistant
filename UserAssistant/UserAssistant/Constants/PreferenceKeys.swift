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
     **String**

     Domain in the preference database where the asset info is stored.
     */
    static let assetInfoDomain = "AssetInfoDomain"

    /**
     **Dictionary**

     Dictionary with key/value pairs matching the display name (key) and keyPath in the assetInfoDomain to read the value from (value).
     */
    static let assetInfoKeys = "AssetInfoKeys"

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
     **Bool**

     Whether the header view should use the default window background color.
     */
    static let showHeaderBackgroundColor = "ShowHeaderBackgroundColor"

    /**
     **String**

     The full path to an image file to be used as the logo (minimum 65 x 65 pixels).
     */
    static let logoPath = "LogoPath"

    /**
     **Float**

     Height of the message window.
     */
    static let windowHeight = "WindowHeight"

    /**
     **Float**

     Width of the message window.
     */
    static let windowWidth = "WindowWidth"
}
