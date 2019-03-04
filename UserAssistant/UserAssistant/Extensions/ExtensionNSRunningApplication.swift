//
//  ExtensionNSRunningApplication.swift
//  UserAssistant
//
//  Created by Erik Berglund on 2018-09-13.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Cocoa

extension NSRunningApplication {

    var bundleName: String? {
        get {
            return self.localizedInfoDictionary?["CFBundleName"] as? String ?? self.infoDictionary?["CFBundleName"] as? String
        }
    }

    var bundleDisplayName: String? {
        get {
            return self.localizedInfoDictionary?["CFBundleDisplayName"] as? String ?? self.infoDictionary?["CFBundleDisplayName"] as? String
        }
    }

    var bundleShortVersion: String {
        get {
            return self.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        }
    }

    var infoDictionary: [String: Any]? {
        guard
            let bundleURL = self.bundleURL,
            let bundle = Bundle(url: bundleURL) else {
                return nil
        }
        return bundle.infoDictionary
    }

    var localizedInfoDictionary: [String: Any]? {
        guard
            let bundleURL = self.bundleURL,
            let bundle = Bundle(url: bundleURL) else {
                return nil
        }
        return bundle.localizedInfoDictionary
    }
}
