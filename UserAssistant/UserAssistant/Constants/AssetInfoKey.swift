//
//  PreferenceKeys.swift
//  UserAssistant
//
//  Created by Erik Berglund on 2018-08-06.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Foundation

struct AssetInfoKey {

    /**
     **String**

     Domain in the preference database where the asset info is stored.
     */
    static let domain = "AssetInfoDomain"

    /**
     **Dictionary**

     Dictionary of key/value pairs to set a display name for the value read from the KeyPath.

     - Key: Display Name
     - Value: KeyPath to a value in the AssetInfoDomain to read the value from.
     */
    static let keys = "AssetInfoKeys"
}
