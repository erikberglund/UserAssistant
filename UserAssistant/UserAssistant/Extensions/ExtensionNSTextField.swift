//
//  ExtensionNSTextField.swift
//  UserAssistant
//
//  Created by Erik Berglund on 2018-08-09.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Cocoa

extension NSTextField {
    func setStringValueAsHTML(_ string: String?, application: NSRunningApplication? = nil) {
        var htmlString = string ?? ""

        // User
        htmlString = htmlString.replacingOccurrences(of: StringVariable.userFullName.rawValue, with: NSFullUserName())

        // Application
        htmlString = htmlString.replacingOccurrences(of: StringVariable.applicationDisplayName.rawValue, with: application?.bundleDisplayName ?? application?.bundleName ?? "")
        htmlString = htmlString.replacingOccurrences(of: StringVariable.applicationVersion.rawValue, with: application?.bundleShortVersion ?? "")

        let stringWithFont = String(format:"<span style=\"font-family: '-apple-system', 'SF Pro Display', 'SF Pro Text', 'HelveticaNeue'; font-size: \(self.font!.pointSize)\">%@</span>", htmlString)
        if let attributedString = stringWithFont.html2AttributedString {
            self.attributedStringValue = attributedString
        } else {
            self.stringValue = htmlString
        }
    }
}
