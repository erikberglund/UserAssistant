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
        - "applicationLaunch"
     */
    case type = "ActionType"

    /**
     **Bool**

     If a force quit should be sent to the application trying to launch.

     NOTE: There is no guarantee that the application will quit. If you need to block applications reliably, use Google's Santa.
     */
    case applicationQuit = "ApplicationQuit"

    /**
     **Array**

     Array of button configurations.
     */
    case buttons = "Buttons"

    /**
     **Array**

     Array of conditions required to match for this action to be activated.
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

     Action must be completed before this this date.
     */
    case dueDate = "DueDate"

    /**
     **Int**

     Number of days before `DueDate` where a warning will be shown when the action is presented.
     */
    case dueDateWarningDays = "DueDateWarningDays"

    /**
     **Dictionary**

     Schedule when to not show this notification.
     */
    case dndSchedule = "DNDSchedule"

    /**
     **Bool**

     Whether this rule should ignore the users do not disturb settings.
     */
    case dndIgnore = "DNDIgnore"

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

     Whether the message should not be indented and instead use the full width of the window.
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
     **Date**

     Action is not valid after this date.
     */
    case notValidAfter = "NotValidAfter"

    /**
     **Date**

     Action is not valid before this date.
     */
    case notValidBefore = "NotValidBefore"

    /**
     **String**

     The title of the message.
     */
    case title = "Title"

    /**
     **Array**

     Array of Trigger dictionaries
     */
    case triggers = "Triggers"

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

    /**
     **Bool**

     Whether the header view should use the default window background color.
     */
    case windowShowHeaderBackgroundColor = "WindowShowHeaderBackgroundColor"
}
