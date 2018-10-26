//
//  AssetInfo.swift
//  UserAssistant
//
//  Created by Erik Berglund on 2018-10-10.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Foundation

class AssetInfo {

    // MARK: -
    // MARK: Static Variables

    static let shared = AssetInfo()

    // MARK: -
    // MARK: Variables

    let userDefaults = UserDefaults(suiteName: "com.schibsted.computer")

    // MARK: -
    // MARK: Computed Variables

    var assetTag: String? {
        return userDefaults?.string(forKey: "asset_tag")
    }
}
