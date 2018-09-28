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
        //  Register current rules defined
        // ---------------------------------------------------------------------
        self.registerActions(isUserLoggingIn: isUserLoggingIn())

        // ---------------------------------------------------------------------
        //  Register observer to be notified when user defaults are updated
        // ---------------------------------------------------------------------
        NotificationCenter.default.addObserver(self, selector: #selector(self.userDefaultsChanged(_:)), name: UserDefaults.didChangeNotification, object: nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {

        // ---------------------------------------------------------------------
        //  Remove observer from notification center
        // ---------------------------------------------------------------------
        // NotificationCenter.default.removeObserver(self) addObserver(self, selector: #selector(self.userDefaultsChanged(_:)), name: UserDefaults.didChangeNotification, object: nil)
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

    @objc func userDefaultsChanged(_ notification: Notification) {
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

