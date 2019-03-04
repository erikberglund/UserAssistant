//
//  MessageWindowBody.swift
//  UserAssistant
//
//  Created by Erik Berglund on 2018-08-06.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Cocoa
import WebKit

class MessageWindowBodyApplication: NSView {

    private let imageViewApplicationIcon = NSImageView()
    private let textFieldApplicationName = NSTextField()
    private let textFieldApplicationPath = NSTextField()
    private let separatorApplication = NSBox(frame: NSRect.zero)

    private let textFieldMessage = NSTextField()
    private let scrollViewMessage = NSScrollView()

    @objc private dynamic var applicationName: String?
    let applicationNameSelector: String

    @objc private dynamic var applicationPath: String?
    let applicationPathSelector: String

    @objc private dynamic var applicationIcon: NSImage?
    let applicationIconSelector: String

    // MARK: -
    // MARK: Intialization

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init() {

        // ---------------------------------------------------------------------
        //  Initialize Key/Value Observing Selector Strings
        // ---------------------------------------------------------------------
        self.applicationNameSelector = NSStringFromSelector(#selector(getter: self.applicationName))
        self.applicationPathSelector = NSStringFromSelector(#selector(getter: self.applicationPath))
        self.applicationIconSelector = NSStringFromSelector(#selector(getter: self.applicationIcon))

        // ---------------------------------------------------------------------
        //  Initialize Self
        // ---------------------------------------------------------------------
        super.init(frame: NSRect.zero)

        // ---------------------------------------------------------------------
        //  Setup interface elements
        // ---------------------------------------------------------------------
        var constraints = [NSLayoutConstraint]()

        self.translatesAutoresizingMaskIntoConstraints = false
        self.setupTextFieldApplicationName(constraints: &constraints)
        self.setupTextFieldApplicationPath(constraints: &constraints)
        self.setupImageViewApplicationIcon(constraints: &constraints)
        self.setupSeparatorApplication(constraints: &constraints)
        self.setupTextFieldMessage(constraints: &constraints)

        // ---------------------------------------------------------------------
        //  Activate Layout Constraints
        // ---------------------------------------------------------------------
        NSLayoutConstraint.activate(constraints)
    }

    // MARK: -
    // MARK: MessageWindowBodyView Methods

    func setupMessage(_ message: String?, application: NSRunningApplication) {

        // ---------------------------------------------------------------------
        //  Set the passed values
        // ---------------------------------------------------------------------
        self.setValue(application.bundleDisplayName ?? application.bundleName ?? application.localizedName , forKey: self.applicationNameSelector)
        self.setValue(application.bundleURL?.path, forKey: self.applicationPathSelector)
        self.setValue(application.icon, forKey: self.applicationIconSelector)

        // ---------------------------------------------------------------------
        //  Update the text field string value to resolve the HTML encoding
        // ---------------------------------------------------------------------
        self.textFieldMessage.setStringValueAsHTML(message, application: application)
    }

    // MARK: -
    // MARK: View Setup

    private func setupTextFieldApplicationName(constraints: inout [NSLayoutConstraint]) {
        self.textFieldApplicationName.translatesAutoresizingMaskIntoConstraints = false
        self.textFieldApplicationName.font = NSFont.modernSystemFont(ofSize: 26, weight: .light)
        self.textFieldApplicationName.isEditable = false
        self.textFieldApplicationName.drawsBackground = false
        self.textFieldApplicationName.isBezeled = false
        self.textFieldApplicationName.alignment = .natural
        self.textFieldApplicationName.textColor = NSColor.labelColor
        self.textFieldApplicationName.lineBreakMode = .byTruncatingTail
        self.textFieldApplicationName.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        self.textFieldApplicationName.bind(NSBindingName.value,
                                       to: self, withKeyPath: self.applicationNameSelector,
                                       options: [NSBindingOption.continuouslyUpdatesValue: true])
        self.addSubview(self.textFieldApplicationName)

        // Top
        constraints.append(NSLayoutConstraint(item:  self.textFieldApplicationName,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: self.imageViewApplicationIcon,
                                              attribute: .top,
                                              multiplier: 1.0,
                                              constant: 2.0))

        // Leading
        constraints.append(NSLayoutConstraint(item:  self.textFieldApplicationName,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self.imageViewApplicationIcon,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: 12.0))

        // Trailing
        constraints.append(NSLayoutConstraint(item:  self,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: self.textFieldApplicationName,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: 55.0))
        
    }

    private func setupTextFieldApplicationPath(constraints: inout [NSLayoutConstraint]) {
        self.textFieldApplicationPath.translatesAutoresizingMaskIntoConstraints = false
        self.textFieldApplicationPath.font = NSFont.modernSystemFont(ofSize: 14, weight: .medium)
        self.textFieldApplicationPath.isEditable = false
        self.textFieldApplicationPath.drawsBackground = false
        self.textFieldApplicationPath.isBezeled = false
        self.textFieldApplicationPath.alignment = .natural
        self.textFieldApplicationPath.textColor = NSColor.secondaryLabelColor
        self.textFieldApplicationPath.lineBreakMode = .byTruncatingTail
        self.textFieldApplicationPath.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        self.textFieldApplicationPath.bind(NSBindingName.value,
                                           to: self, withKeyPath: self.applicationPathSelector,
                                           options: [NSBindingOption.continuouslyUpdatesValue: true])
        self.addSubview(self.textFieldApplicationPath)

        // Top
        constraints.append(NSLayoutConstraint(item:  self.textFieldApplicationPath,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: self.textFieldApplicationName,
                                              attribute: .bottom,
                                              multiplier: 1.0,
                                              constant: 4.0))

        // Leading
        constraints.append(NSLayoutConstraint(item:  self.textFieldApplicationPath,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self.textFieldApplicationName,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: 0.0))

        // Trailing
        constraints.append(NSLayoutConstraint(item:  textFieldApplicationPath,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: self.textFieldApplicationName,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: 0.0))

    }

    private func setupImageViewApplicationIcon(constraints: inout [NSLayoutConstraint]) {
        self.imageViewApplicationIcon.translatesAutoresizingMaskIntoConstraints = false
        self.imageViewApplicationIcon.imageScaling = .scaleProportionallyUpOrDown
        self.imageViewApplicationIcon.setContentHuggingPriority(.required, for: .horizontal)
        self.imageViewApplicationIcon.setContentHuggingPriority(.required, for: .vertical)
        self.imageViewApplicationIcon.bind(NSBindingName.image,
                                       to: self, withKeyPath: self.applicationIconSelector,
                                       options: [NSBindingOption.continuouslyUpdatesValue: true])
        self.addSubview(self.imageViewApplicationIcon)

        // Height
        constraints.append(NSLayoutConstraint(item:  self.imageViewApplicationIcon,
                                              attribute: .height,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1.0,
                                              constant: 65.0))

        // Width == Height
        constraints.append(NSLayoutConstraint(item:  self.imageViewApplicationIcon,
                                              attribute: .width,
                                              relatedBy: .equal,
                                              toItem: self.imageViewApplicationIcon,
                                              attribute: .height,
                                              multiplier: 1.0,
                                              constant: 0.0))

        // Top
        constraints.append(NSLayoutConstraint(item:  self.imageViewApplicationIcon,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .top,
                                              multiplier: 1.0,
                                              constant: 20.0))

        // Leading
        constraints.append(NSLayoutConstraint(item:  self.imageViewApplicationIcon,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: 20.0))
    }

    private func setupSeparatorApplication(constraints: inout [NSLayoutConstraint]) {
        self.separatorApplication.translatesAutoresizingMaskIntoConstraints = false
        self.separatorApplication.boxType = .separator
        self.addSubview(self.separatorApplication)

        // Top
        constraints.append(NSLayoutConstraint(item:  self.separatorApplication,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: self.imageViewApplicationIcon,
                                              attribute: .bottom,
                                              multiplier: 1.0,
                                              constant: 4.0))

        // Leading
        constraints.append(NSLayoutConstraint(item:  self.separatorApplication,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self.textFieldApplicationName,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: 0.0))

        // Trailing
        constraints.append(NSLayoutConstraint(item:  self.textFieldMessage,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: self.separatorApplication,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: 0.0))
    }

    private func setupTextFieldMessage(constraints: inout [NSLayoutConstraint]) {
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
                                              toItem: self.separatorApplication,
                                              attribute: .bottom,
                                              multiplier: 1.0,
                                              constant: 30.0))

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
                                              toItem: self.textFieldApplicationName,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: 0.0))

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
