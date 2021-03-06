//
//  Action.swift
//  UserAssistant
//
//  Created by Erik Berglund on 2018-08-27.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Foundation
import Cocoa

class Action {

    // Application
    // Here a reference to the applications this rule will block. They will be removed once the block prompt has been shown.
    var applications = [NSRunningApplication]()
    var applicationQuit: Bool = false

    // Configuration
    let configuration: [String: Any]
    let identifier: String

    // Type
    let type: ActionType

    // Triggers
    var triggers: Triggers?

    // Buttons
    var buttonConfiguration: [[String: Any]]?

    // Conditions
    var conditions: Conditions?
    var conditionsAction = ConditionsAction.message
    var conditionsRequired: Conditions?

    // Contact
    var contactHidden = false
    var contactMessageValue: [String: String]?
    var contactMessage: [String: String]? {
        return self.contactMessageValue ?? UserDefaults.standard.dictionary(forKey: PreferenceKey.contactMessage) as? [String: String]
    }
    var contactMethodsValue: [String]?
    var contactMethods: [String]? {
        return self.contactMethodsValue ?? UserDefaults.standard.array(forKey: PreferenceKey.contactMethods) as? [String]
    }

    // Do Not Disturb
    var dndIgnore: Bool = false
    var dndSchedule: Schedule?

    // Date
    var notValidBefore: Date?
    var notValidAfter: Date?
    var dueDate: Date?
    var dueDateWarningDays: Int?

    // Message
    var message: [String: String]?
    let messageTitle: [String: String]
    var messageType: MessageType = .messageFullScreen
    var messageDescription: [String: String]?
    var messageFullSizeContent: Bool = false
    var messageURL: String?

    // Icon
    var iconPath: String?
    var iconSaved: NSImage?
    var icon: NSImage? {
        if
            self.iconSaved == nil,
            let iconPath = self.iconPath ?? UserDefaults.standard.string(forKey: PreferenceKey.logoPath) {
            self.iconSaved = NSImage(contentsOfFile: iconPath)
        }
        return self.iconSaved
    }

    // Window
    var windowWidth: CGFloat?
    var windowHeight: CGFloat?
    var windowShowHeaderBackgroundColor = false

    // MARK: -
    // MARK: Initialization

    init?(identifier: String, configuration: [String: Any]) throws {

        self.configuration = configuration
        self.identifier = identifier

        // ActionType
        guard
            let typeString = configuration[ActionKey.type.rawValue] as? String,
            let type = ActionType(rawValue: typeString) else {
                throw NSError.init(domain: "test", code: -2, userInfo: nil)
        }
        self.type = type

        // Title
        guard let title = configuration[ActionKey.title.rawValue] as? [String: String] else {
            throw NSError.init(domain: "test", code: -3, userInfo: nil)
        }
        self.messageTitle = title

        // ---------------------------------------------------------------------
        //  Initialize non-required variables
        // ---------------------------------------------------------------------
        for (key, element) in configuration {
            try self.initialize(key: key, value: element)
        }
    }

    private func initialize(key: String, value: Any?) throws {
        guard let actionKey = ActionKey(rawValue: key) else {
            Swift.print("Unknown ActionKey will be ignored: \(key)")
            return
        }

        if [ActionKey.type.rawValue, ActionKey.title.rawValue].contains(key) { return }

        switch actionKey {
        case .applicationQuit:
            if let applicationQuit = value as? Bool {
                self.applicationQuit = applicationQuit
            }
            
        case .buttons:
            if let buttonConfiguration = value as? [[String: Any]] {
                self.buttonConfiguration = buttonConfiguration
            }

        case .conditions:
            if let conditionsConfiguration = value as? [[String: [String: Any]]] {
                self.conditions = try Conditions(configuration: conditionsConfiguration)
            }

        case .conditionsRequired:
            if let conditionsRequired = value as? [[String: [String: Any]]] {
                self.conditionsRequired = try Conditions(configuration: conditionsRequired)
            }

        case .contactHidden:
            if let contactHidden = value as? Bool {
                self.contactHidden = contactHidden
            }

        case .contactMessage:
            if let contactMessageValue = value as? [String: String] {
                self.contactMessageValue = contactMessageValue
            }

        case .contactMethods:
            if let contactMethodsValue = value as? [String] {
                self.contactMethodsValue = contactMethodsValue
            }

        case .notValidAfter:
            if let notValidAfter = value as? Date {
                self.notValidAfter = notValidAfter
            }

        case .notValidBefore:
            if let notValidBefore = value as? Date {
                self.notValidBefore = notValidBefore
            }

        case .dueDate:
            if let dueDate = value as? Date {
                self.dueDate = dueDate
            }

        case .dueDateWarningDays:
            if let dueDateWarningDays = value as? Int {
                self.dueDateWarningDays = dueDateWarningDays
            }

        case .dndIgnore:
            if let dndIgnore = value as? Bool {
                self.dndIgnore = dndIgnore
            }

        case .dndSchedule:
            if let dndScheduleDict = value as? [String: Any], let dndSchedule = try Schedule(dndScheduleDict) {
                self.dndSchedule = dndSchedule
            }

        case .windowShowHeaderBackgroundColor:
            if let windowShowHeaderBackgroundColor = value as? Bool {
                self.windowShowHeaderBackgroundColor = windowShowHeaderBackgroundColor
            }

        case .triggers:
            if let triggerArray = value as? [[String: Any]] {
                self.triggers = try Triggers(triggerArray)
            }

        case .message:
            if let message = value as? [String: String] {
                self.message = message
            }

        case .messageType:
            if let messageTypeString = value as? String, let messageType = MessageType(rawValue: messageTypeString) {
                self.messageType = messageType
            }

        case .messageDescription:
            if let description = value as? [String: String] {
                self.messageDescription = description
            }

        case .messageFullSizeContent:
            if let messageFullSizeContent = value as? Bool {
                self.messageFullSizeContent = messageFullSizeContent
            }

        case .messageURL:
            if let messageURL = value as? String {
                self.messageURL = messageURL
            }

        case .windowWidth:
            if let windowWidth = value as? CGFloat {
                self.windowWidth = windowWidth
            }

        case .windowHeight:
            if let windowHeight = value as? CGFloat {
                self.windowHeight = windowHeight
            }

        case .type,
             .title:
            return
        }
    }

    func shouldRegister(completionHandler: @escaping (_ status: Bool) -> Void) {

        // Get the ConditionsRequired array, if none exist, the action will be registered automatically.
        guard let conditions = self.conditionsRequired else {
            completionHandler(true)
            return
        }

        conditions.verifyAll { (status, error) in
            completionHandler(status == .failed ? false : true)
        }
    }

    func nextScheduledTrigger() -> Date? {
        return self.triggers?.nextScheduledTrigger(dndSchedule: self.dndSchedule)
    }

    func unRegister() {
        switch self.type {
        case .applicationLaunch:
            ActionApplication.shared.unRegister(action: self)
        case .message:
            ActionMessage.shared.unRegister(action: self)
        case .notification:
            Swift.print("Not Done")
        }
    }
}

extension Action {
    func verifyConditions(completionHandler: @escaping (_ conditionStatus: ConditionStatus, _ error: String?) -> Void) {
        guard let conditions = self.conditions else {
            completionHandler(.pass, nil)
            return
        }

        if let application = self.applications.first {
            self.verifyConditions(application, completionHandler: completionHandler)
        } else {
            conditions.verifyAll(completionHandler: completionHandler)
        }
    }

    func verifyConditions(_ application: NSRunningApplication, completionHandler: @escaping (_ conditionStatus: ConditionStatus, _ error: String?) -> Void) {
        guard let conditions = self.conditions else {
            completionHandler(.failed, nil)
            return
        }
        conditions.verify(application: application, completionHandler: completionHandler)
    }
}

extension Action: Hashable {
    var hashValue: Int {
        return self.identifier.hashValue
    }

    static func == (lhs: Action, rhs: Action) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
