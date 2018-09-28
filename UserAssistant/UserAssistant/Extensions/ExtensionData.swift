//
//  ExtensionData.swift
//  UserAssistant
//
//  Created by Erik Berglund on 2018-08-22.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Foundation

extension Data {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self,
                                          options: [.documentType: NSAttributedString.DocumentType.html,
                                                    .characterEncoding: String.Encoding.utf8.rawValue],
                                          documentAttributes: nil)
        } catch {
            return nil
        }
    }

    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}
