//
//  ActionKeys.swift
//  UserAssistant
//
//  Created by Erik Berglund on 2018-08-27.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Foundation

enum ActionKey: String {

    /**
     **String**

     The type of action.

     Allowed values:
        - "message" (default)
        - "notification"
        - "applicationBlock"
        - "applicationWarn"
     */
    case type = "ActionType"

    /**
     **Array**

     Array of button configurations.
     */
    case buttons = "Buttons"

    /**
     **Array**

     Array of conditions required to match this action.
     */
    case conditions = "Conditions"

    /**
     **String**

     Array of conditions required to load this action.
     */
    case conditionsRequired = "ConditionsRequired"

    /**
     **Bool**

     If the contact message and methods should be hidden.
     */
    case contactHidden = "ContactHidden"

    /**
     **String**

     The contact message to display at the bottom of the message window.
     */
    case contactMessage = "ContactMessage"

    /**
     **Array**

     The contact methods to list below the contact message at the bottom of the message window.
     */
    case contactMethods = "ContactMethods"

    /**
     **Date**

     Date after which the action will be allowed.
     */
    case dateStart = "DateStart"

    /**
     **Date**

     Date after which the action will not be allowed.
     */
    case dateEnd = "DateEnd"

    /**
     **Date**

     Date before the action must be completed. A countdown in the message will be shown.
     */
    case dateRequired = "DateRequired"

    /**
     **Int**

     Number of days before the dateRequired where the message should start warn the user that an action must be performed.
     */
    case dateRequiredWarningDays = "DateRequiredWarningDays"

    /**
     **Dictionary**

     Schedule where to not show this notification.
     */
    case dndSchedule = "DNDSchedule"

    /**
     **Bool**

     Whether this rule should ignore the users do not disturb settings.
     */
    case dndIgnore = "DNDIgnore"

    /**
     **Bool**

     Whether the header view should use the default window background color.
     */
    case showHeaderBackgroundColor = "ShowHeaderBackgroundColor"

    /**
     **Array**

     Array of Trigger dictionaries
     */
    case triggers = "Triggers"

    /**
     **Dictionary**

     The message body.

     Dictionary with keys for each localized message.
     */
    case message = "Message"

    /**
     **String**

     A short sub-title of the message.
     */
    case messageDescription = "Description"

    /**
     **Bool**

     Whether the HTML message should be shown in full size content view or indented as the regular message.
     */
    case messageFullSizeContent = "MessageFullSizeContent"

    /**
     **String**

     The message type.

     Allowed values:
        - "message"
        - "messageFullScreen" (default)
        - "notification"
     */
    case messageType = "MessageType"

    /**
     **String**

     URL to load as message body.
     */
    case messageURL = "MessageURL"

    /**
     **String**

     The title of the message.
     */
    case title = "Title"

    /**
     **Float**

     Height of the message window.
     */
    case windowHeight = "WindowHeight"

    /**
     **Float**

     Width of the message window.
     */
    case windowWidth = "WindowWidth"
}
