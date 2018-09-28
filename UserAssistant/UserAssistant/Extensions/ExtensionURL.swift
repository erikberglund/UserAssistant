//
//  ExtensionURL.swift
//  UserAssistant
//
//  Created by Erik Berglund on 2018-09-03.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Foundation

extension URL {

    var typeIdentifier: String {
        do {
            if let uti = try self.resourceValues(forKeys: [.typeIdentifierKey]).typeIdentifier {
                return uti
            }
        } catch {
            Swift.print("Failed getting uti for: \(self.path) with error: \(error)")
        }

        if let unmanagedFileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, self.pathExtension as CFString, nil) {
            return unmanagedFileUTI.takeRetainedValue() as String
        } else {
            return kUTTypeItem as String
        }
    }
}
