//
//  ExtensionNSTextField.swift
//  UserAssistant
//
//  Created by Erik Berglund on 2018-08-09.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Cocoa

extension NSTextField {
    func setStringValueAsHTML(_ string: String?) {
        var htmlString = string ?? ""
        htmlString = htmlString.replacingOccurrences(of: "%USERFULLNAME%", with: NSFullUserName())
        let stringWithFont = String(format:"<span style=\"font-family: '-apple-system', 'SF Pro Display', 'SF Pro Text', 'HelveticaNeue'; font-size: \(self.font!.pointSize)\">%@</span>", htmlString)
        if let attributedString = stringWithFont.html2AttributedString {
            self.attributedStringValue = attributedString
        } else {
            self.stringValue = htmlString
        }
    }
}
