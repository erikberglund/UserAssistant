//
//  ExtensionOperatingSystemVersion.swift
//  UserAssistant
//
//  Created by Erik Berglund on 2018-08-22.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Foundation

extension OperatingSystemVersion {

    init?(versionString: String) {
        let versionStringArray = versionString.components(separatedBy: ".")

        guard let majorVersion = Int(versionStringArray[0]) else { return nil }

        var minorVersion = 0
        if 1 < versionStringArray.count {
            guard let minorVersionInt = Int(versionStringArray[1]) else { return nil }
            minorVersion = minorVersionInt
        }

        var patchVersion = 0
        if 2 < versionStringArray.count {
            guard let patchVersionInt = Int(versionStringArray[2]) else { return nil }
            patchVersion = patchVersionInt
        }

        self.init(majorVersion: majorVersion, minorVersion: minorVersion, patchVersion: patchVersion)
    }

    static func == (lhs: OperatingSystemVersion, rhs: OperatingSystemVersion) -> Bool {
        return
            lhs.majorVersion == rhs.majorVersion &&
            lhs.minorVersion == rhs.minorVersion &&
            lhs.patchVersion == rhs.patchVersion
    }

    static func != (lhs: OperatingSystemVersion, rhs: OperatingSystemVersion) -> Bool {
        return !(lhs == rhs)
    }
}
