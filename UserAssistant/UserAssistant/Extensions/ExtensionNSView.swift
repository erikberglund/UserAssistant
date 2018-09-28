//
//  ExtensionNSView.swift
//  UserAssistant
//
//  Created by Erik Berglund on 2018-08-08.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Cocoa

extension NSView {
    func removeSubviews() {
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
    }
}
