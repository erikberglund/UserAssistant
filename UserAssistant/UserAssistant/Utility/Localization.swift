//
//  Localization.swift
//  UserAssistant
//
//  Created by Erik Berglund on 2018-09-14.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Foundation

func localizedString(for dictionary: [String: String]?) -> String {
    var string: String = ""
    for localization in Locale.preferredLanguages {
        let language = localization.components(separatedBy: "-").first ?? "en"
        if let localizedString = dictionary?[language] {
            string = localizedString
            break
        }
    }

    if string.isEmpty {
        if let defaultString = dictionary?["default"] {
            string = defaultString
        } else if let enString = dictionary?["en"] {
            string = enString
        }
    }

    return string
}
