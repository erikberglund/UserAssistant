//
//  ButtonKeys.swift
//  UserAssistant
//
//  Created by Erik Berglund on 2018-08-30.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Foundation

struct ButtonKey {

    /**
     **Bool**

     Whether the button should be the default button or not.
     */
    static let isDefault = "IsDefault"

    /**
     **String**

     A link to open in the default application when the button is clicked.
     */
    static let link = "Link"

    /**
     **String**

     A path to open in the default application when the button is clicked.
     */
    static let path = "Path"

    /**
     **String**

     Script to run when the button is clicked.
     */
    static let script = "Script"

    /**
     **String**

     The title of the button.
     */
    static let title = "Title"
}
