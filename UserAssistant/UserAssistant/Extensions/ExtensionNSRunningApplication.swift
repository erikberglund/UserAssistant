//
//  ExtensionNSRunningApplication.swift
//  UserAssistant
//
//  Created by Erik Berglund on 2018-09-13.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Cocoa

extension NSRunningApplication {
    var infoDictionary: [String: Any]? {
        guard
            let bundleURL = self.bundleURL,
            let bundle = Bundle(url: bundleURL) else {
                return nil
        }
        return bundle.infoDictionary
    }
}
