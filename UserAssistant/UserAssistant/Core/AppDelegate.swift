//
//  AppDelegate.swift
//  UserAssistant
//
//  Created by Erik Berglund on 2018-08-06.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        // ---------------------------------------------------------------------
        //  Register default preferences
        // ---------------------------------------------------------------------
        self.registerUserDefaults()
        self.registerConstants()

        // ---------------------------------------------------------------------
        //  Register actions currently configured
        // ---------------------------------------------------------------------
        self.registerActions(isUserLoggingIn: isUserLoggingIn())

        // ---------------------------------------------------------------------
        //  Register observer to be notified when user defaults are updated
        // ---------------------------------------------------------------------
        DistributedNotificationCenter.default().addObserver(forName: .MCXManagementStatusChangedForDomains,
                                                            object: "com.apple.MCX",
                                                            queue: nil,
                                                            using: self.mcxManagementStatusChangedForDomains)

        // ---------------------------------------------------------------------
        //  Show menu bar icon configured in the application preferences
        // ---------------------------------------------------------------------
        if UserDefaults.standard.bool(forKey: PreferenceKey.showMenuBarIcon) {
            MenuItem.shared.showMenuItem()
        }

        
        do {
            try HelperAuthorization.authorizationRightsUpdateDatabase()
            //try HelperConnection.shared.helperInstall()
        } catch {
            Swift.print("error: \(error)")
        }
         
    }

    private func registerUserDefaults() {

        // ---------------------------------------------------------------------
        //  Get URL to application default settings
        // ---------------------------------------------------------------------
        guard let defaultSettingsURL = Bundle.main.url(forResource: "DefaultPreferences", withExtension: "plist") else { return }

        // ---------------------------------------------------------------------
        //  Register default settings with UserDefaults
        // ---------------------------------------------------------------------
        if let defaultSettings = NSDictionary(contentsOf: defaultSettingsURL) as? [String : Any] {
            UserDefaults.standard.register(defaults: defaultSettings)
        }
    }

    private func registerConstants() {

        // ---------------------------------------------------------------------
        //  Width
        // ---------------------------------------------------------------------
        if let windowWidth = UserDefaults.standard.value(forKey: PreferenceKey.windowWidth) as? Float {
            MessageWindowSize.width = CGFloat(windowWidth < 600.0 ? 600.0 : windowWidth)
        }

        // ---------------------------------------------------------------------
        //  Height
        // ---------------------------------------------------------------------
        if let windowHeight = UserDefaults.standard.value(forKey: PreferenceKey.windowHeight) as? Float {
            MessageWindowSize.height = CGFloat(windowHeight < 400.0 ? 400.0 : windowHeight)
        }
    }

    @objc func mcxManagementStatusChangedForDomains(_ notification: Notification) {
        guard
            let bundleID = Bundle.main.bundleIdentifier,
            let domains = notification.userInfo?["com.apple.MCX.changedDomains"] as? [String],
            domains.contains(bundleID) else { return }
        self.registerActions(isUserLoggingIn: false)
    }

    private func registerActions(isUserLoggingIn: Bool) {

        // ---------------------------------------------------------------------
        //  Get entire defaults domain
        // ---------------------------------------------------------------------
        let userDefaultsDictionary = UserDefaults.standard.dictionaryRepresentation()

        Actions.shared.register(keys: userDefaultsDictionary.keys.filter({ $0.starts(with: kActionPrefix) }),
                                dict: userDefaultsDictionary.filter({ $0.key.starts(with: kActionPrefix) }),
                                isUserLoggingIn: isUserLoggingIn)
    }
}

