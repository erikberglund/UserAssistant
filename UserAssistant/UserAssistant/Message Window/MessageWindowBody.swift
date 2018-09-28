//
//  MessageWindowBody.swift
//  UserAssistant
//
//  Created by Erik Berglund on 2018-08-06.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Cocoa
import WebKit

class MessageWindowBodyView: NSView {

    private let textFieldMessage = NSTextField()
    private let scrollViewMessage = NSScrollView()

    // MARK: -
    // MARK: Intialization

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init() {

        // ---------------------------------------------------------------------
        //  Initialize Self
        // ---------------------------------------------------------------------
        super.init(frame: NSRect.zero)

        // ---------------------------------------------------------------------
        //  Setup interface elements
        // ---------------------------------------------------------------------
        var constraints = [NSLayoutConstraint]()

        self.translatesAutoresizingMaskIntoConstraints = false
        self.setupTextFieldMessage(constraints: &constraints)

        // ---------------------------------------------------------------------
        //  Activate Layout Constraints
        // ---------------------------------------------------------------------
        NSLayoutConstraint.activate(constraints)
    }

    // MARK: -
    // MARK: MessageWindowBodyView Methods

    func setupMessage(_ message: String?) {

        // ---------------------------------------------------------------------
        //  Update the text field string value to resolve the HTML encoding
        // ---------------------------------------------------------------------
        self.textFieldMessage.setStringValueAsHTML(message)
    }

    // MARK: -
    // MARK: View Setup

    internal func setupTextFieldMessage(constraints: inout [NSLayoutConstraint]) {
        self.textFieldMessage.translatesAutoresizingMaskIntoConstraints = false
        self.textFieldMessage.lineBreakMode = .byWordWrapping
        self.textFieldMessage.isBordered = false
        self.textFieldMessage.isBezeled = false
        self.textFieldMessage.drawsBackground = false
        self.textFieldMessage.isEditable = false
        self.textFieldMessage.isSelectable = false
        self.textFieldMessage.font = NSFont.modernSystemFont(ofSize: 19, weight: .regular)
        self.textFieldMessage.textColor = NSColor.labelColor
        self.textFieldMessage.alignment = .left
        self.textFieldMessage.setContentHuggingPriority(.defaultLow, for: .horizontal)
        self.textFieldMessage.setContentHuggingPriority(.defaultLow, for: .vertical)
        self.textFieldMessage.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        self.textFieldMessage.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        self.textFieldMessage.preferredMaxLayoutWidth = (MessageWindowSize.width - (26.0 * 2))
        self.addSubview(self.textFieldMessage)

        // Top
        constraints.append(NSLayoutConstraint(item:  self.textFieldMessage,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .top,
                                              multiplier: 1.0,
                                              constant: 20.0))

        // Bottom
        constraints.append(NSLayoutConstraint(item:  self,
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: self.textFieldMessage,
                                              attribute: .bottom,
                                              multiplier: 1.0,
                                              constant: 22.0))

        // Leading
        constraints.append(NSLayoutConstraint(item:  self.textFieldMessage,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: 55.0))

        // Trailing
        constraints.append(NSLayoutConstraint(item: self,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: self.textFieldMessage,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: 55.0))
    }
}
