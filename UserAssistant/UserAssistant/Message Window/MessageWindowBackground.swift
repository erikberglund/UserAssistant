//
//  MessageWindowBackground.swift
//  UserAssistant
//
//  Created by Erik Berglund on 2018-08-29.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Foundation
import Cocoa

class MessageWindowBackground: NSWindow {

    init(contentRect: NSRect) {
        super.init(contentRect: contentRect, styleMask: .fullScreen, backing: .buffered, defer: true)

        self.isReleasedWhenClosed = false
        self.backgroundColor = .white

        let visualEffectView = NSVisualEffectView()
        visualEffectView.blendingMode = .behindWindow
        visualEffectView.material = .dark
        visualEffectView.state = .active

        self.contentView = visualEffectView
    }

    func show() {
        self.toggleFullScreen(self)
    }
}
