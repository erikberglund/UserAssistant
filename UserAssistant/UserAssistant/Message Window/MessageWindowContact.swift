//
//  MessageWindowContact.swift
//  UserAssistant
//
//  Created by Erik Berglund on 2018-08-08.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Cocoa

class MessageWindowContactView: NSView {

    private let textFieldMessage = NSTextField()
    private let textFieldMethods = NSTextField()

    private var message: String?
    private var methods: String?

    var height: CGFloat = 0.0

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
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setupTextFieldMessage()
        self.setupTextFieldMethods()
    }

    // MARK: -
    // MARK: MessageWindowContactView Methods

    func setupContact(withMessage message: String?, methods: [String]?) {

        var methodsString: String = ""
        if let methodsArray = methods {
            methodsString = methodsArray.joined(separator: " | ")
        }

        let uiNeedsUpdate = message != self.message || methodsString != self.methods

        // ---------------------------------------------------------------------
        //  Set the passed values
        // ---------------------------------------------------------------------
        self.message = message
        self.methods = methodsString

        // ---------------------------------------------------------------------
        //  Setup the interface elements depending on the current values
        //  The order of these are important as they look at the previous state
        // ---------------------------------------------------------------------
        if uiNeedsUpdate {
            var constraints = [NSLayoutConstraint]()
            self.height = 0.0

            self.removeSubviews()

            self.configureTextFieldMessage(constraints: &constraints)
            self.configureTextFieldMethods(constraints: &constraints)

            constraints.append(NSLayoutConstraint(item: self,
                                                  attribute: .height,
                                                  relatedBy: .equal,
                                                  toItem: nil,
                                                  attribute: .notAnAttribute,
                                                  multiplier: 1.0,
                                                  constant: self.height))

            // ---------------------------------------------------------------------
            //  Activate Layout Constraints
            // ---------------------------------------------------------------------
            NSLayoutConstraint.activate(constraints)
        }
    }

    // MARK: -
    // MARK: View Configuration

    private func configureTextFieldMessage(constraints: inout [NSLayoutConstraint]) {
        guard self.message != nil else { return }
        self.textFieldMessage.stringValue = self.message ?? ""
        self.addSubview(self.textFieldMessage)
        self.height += self.textFieldMessage.intrinsicContentSize.height

        // Leading
        constraints.append(NSLayoutConstraint(item: self.textFieldMessage,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .leading,
                                              multiplier: 1,
                                              constant: 26.0))

        // Trailing
        constraints.append(NSLayoutConstraint(item: self,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: self.textFieldMessage,
                                              attribute: .trailing,
                                              multiplier: 1,
                                              constant: 26.0))

        // Bottom
        if self.methods != nil {
            constraints.append(NSLayoutConstraint(item: self.textFieldMethods,
                                                  attribute: .top,
                                                  relatedBy: .equal,
                                                  toItem: self.textFieldMessage,
                                                  attribute: .bottom,
                                                  multiplier: 1,
                                                  constant: 3.0))
            self.height += 3.0
        } else {
            constraints.append(NSLayoutConstraint(item: self,
                                                  attribute: .bottom,
                                                  relatedBy: .equal,
                                                  toItem: self.textFieldMessage,
                                                  attribute: .bottom,
                                                  multiplier: 1,
                                                  constant: 22.0))
            self.height += 22.0
        }
    }

    private func configureTextFieldMethods(constraints: inout [NSLayoutConstraint]) {
        guard self.methods != nil else { return }
        self.textFieldMethods.stringValue = self.methods ?? ""
        self.addSubview(self.textFieldMethods)
        self.height += self.textFieldMethods.intrinsicContentSize.height

        // Leading
        constraints.append(NSLayoutConstraint(item: self.textFieldMethods,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .leading,
                                              multiplier: 1,
                                              constant: 26.0))

        // Trailing
        constraints.append(NSLayoutConstraint(item: self,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: self.textFieldMethods,
                                              attribute: .trailing,
                                              multiplier: 1,
                                              constant: 26.0))

        // Bottom
        constraints.append(NSLayoutConstraint(item: self,
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: self.textFieldMethods,
                                              attribute: .bottom,
                                              multiplier: 1,
                                              constant: 22.0))
        self.height += 22.0
    }

    // MARK: -
    // MARK: View Setup

    internal func setupTextFieldMessage() {
        self.textFieldMessage.translatesAutoresizingMaskIntoConstraints = false
        self.textFieldMessage.lineBreakMode = .byWordWrapping
        self.textFieldMessage.isBordered = false
        self.textFieldMessage.isBezeled = false
        self.textFieldMessage.drawsBackground = false
        self.textFieldMessage.isEditable = false
        self.textFieldMessage.isSelectable = false
        self.textFieldMessage.font = NSFont.modernSystemFont(ofSize: 14, weight: .regular)
        self.textFieldMessage.textColor = NSColor.controlShadowColor
        self.textFieldMessage.alignment = .center
        self.textFieldMessage.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        self.textFieldMessage.preferredMaxLayoutWidth = (MessageWindowSize.width - (26.0 * 2))
    }

    internal func setupTextFieldMethods() {
        self.textFieldMethods.translatesAutoresizingMaskIntoConstraints = false
        self.textFieldMethods.lineBreakMode = .byWordWrapping
        self.textFieldMethods.isBordered = false
        self.textFieldMethods.isBezeled = false
        self.textFieldMethods.drawsBackground = false
        self.textFieldMethods.isEditable = false
        self.textFieldMethods.isSelectable = false
        self.textFieldMethods.font = NSFont.modernSystemFont(ofSize: 14, weight: .regular)
        self.textFieldMethods.textColor = NSColor.controlShadowColor
        self.textFieldMethods.alignment = .center
        self.textFieldMethods.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        self.textFieldMethods.preferredMaxLayoutWidth = (MessageWindowSize.width - (26.0 * 2))
    }
}
