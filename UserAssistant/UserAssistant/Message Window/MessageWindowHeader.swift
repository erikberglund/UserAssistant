//
//  MessageWindowHeader.swift
//  UserAssistant
//
//  Created by Erik Berglund on 2018-08-06.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Cocoa

class MessageWindowHeaderView: NSView {

    private let imageViewIcon = NSImageView()
    private let textFieldTitle = NSTextField()
    private let textFieldDescription = NSTextField()
    private var backgroundColor: NSColor = .white

    @objc private dynamic var messageTitle: String?
    let messageTitleSelector: String

    @objc private dynamic var messageDescription: String?
    let messageDescriptionSelector: String

    @objc private dynamic var messageIcon: NSImage?
    let messageIconSelector: String

    // MARK: -
    // MARK: Intialization

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init() {

        // ---------------------------------------------------------------------
        //  Initialize Key/Value Observing Selector Strings
        // ---------------------------------------------------------------------
        self.messageTitleSelector = NSStringFromSelector(#selector(getter: self.messageTitle))
        self.messageDescriptionSelector = NSStringFromSelector(#selector(getter: self.messageDescription))
        self.messageIconSelector = NSStringFromSelector(#selector(getter: self.messageIcon))

        // ---------------------------------------------------------------------
        //  Initialize Self
        // ---------------------------------------------------------------------
        super.init(frame: NSRect.zero)

        // ---------------------------------------------------------------------
        //  Setup interface elements
        // ---------------------------------------------------------------------
        var constraints = [NSLayoutConstraint]()

        self.wantsLayer = true
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setupTextFieldTitle()
        self.setupTextFieldDescription()
        self.setupImageViewIcon(constraints: &constraints)

        // ---------------------------------------------------------------------
        //  Activate Layout Constraints
        // ---------------------------------------------------------------------
        NSLayoutConstraint.activate(constraints)
    }

    // MARK: -
    // MARK: MessageWindowHeaderView Methods

    func setupHeader(withTitle title: String, description: String?, icon: NSImage?, showBackground: Bool) {

        self.layer?.backgroundColor = showBackground ? NSColor.windowBackgroundColor.cgColor : NSColor.white.cgColor

        let uiNeedsUpdate = self.messageTitle == nil || description != self.messageDescription || icon != self.messageIcon

        // ---------------------------------------------------------------------
        //  Set the passed values
        // ---------------------------------------------------------------------
        self.setValue(title, forKey: self.messageTitleSelector)
        self.setValue(description, forKey: self.messageDescriptionSelector)
        self.setValue(icon, forKey: self.messageIconSelector)

        // ---------------------------------------------------------------------
        //  Setup the interface elements depending on the current values
        //  The order of these are important as they look at the previous state
        // ---------------------------------------------------------------------
        if uiNeedsUpdate {
            var constraints = [NSLayoutConstraint]()

            self.removeSubviews()

            self.configureIcon(constraints: &constraints)
            self.configureTitle(constraints: &constraints)
            self.configureDescription(constraints: &constraints)

            // ---------------------------------------------------------------------
            //  Activate Layout Constraints
            // ---------------------------------------------------------------------
            NSLayoutConstraint.activate(constraints)
        }
    }

    // MARK: -
    // MARK: View Configuration

    private func configureTitle(constraints: inout [NSLayoutConstraint]) {
        self.addSubview(self.textFieldTitle)

        // ---------------------------------------------------------------------
        //  Top
        // ---------------------------------------------------------------------
        if let messageDescription = self.messageDescription, !messageDescription.isEmpty {
            self.textFieldTitle.font = NSFont.modernSystemFont(ofSize: 34, weight: .light)
            self.textFieldTitle.alignment = .natural
            constraints.append(NSLayoutConstraint(item:  self.textFieldTitle,
                                                  attribute: .top,
                                                  relatedBy: .equal,
                                                  toItem: self,
                                                  attribute: .top,
                                                  multiplier: 1.0,
                                                  constant: 17.0))
        } else {
            self.textFieldTitle.font = NSFont.modernSystemFont(ofSize: 36.0, weight: .light)
            self.textFieldTitle.alignment = .center
            constraints.append(NSLayoutConstraint(item:  self.textFieldTitle,
                                                  attribute: .centerY,
                                                  relatedBy: .equal,
                                                  toItem: self,
                                                  attribute: .centerY,
                                                  multiplier: 1.0,
                                                  constant: 0.0))
        }

        // ---------------------------------------------------------------------
        //  Leading / Trailing
        // ---------------------------------------------------------------------
        if self.messageIcon == nil {
            constraints.append(NSLayoutConstraint(item:  self.textFieldTitle,
                                                  attribute: .leading,
                                                  relatedBy: .equal,
                                                  toItem: self,
                                                  attribute: .leading,
                                                  multiplier: 1.0,
                                                  constant: 20.0))
            constraints.append(NSLayoutConstraint(item: self,
                                                  attribute: .trailing,
                                                  relatedBy: .equal,
                                                  toItem: self.textFieldTitle,
                                                  attribute: .trailing,
                                                  multiplier: 1.0,
                                                  constant: 8.0))
        } else {
            constraints.append(NSLayoutConstraint(item:  self.textFieldTitle,
                                                  attribute: .leading,
                                                  relatedBy: .equal,
                                                  toItem: self.imageViewIcon,
                                                  attribute: .trailing,
                                                  multiplier: 1.0,
                                                  constant: 12.0))

            // FIXME: Should probably calculate the percentage increase/decrease from the original window vs new window width and appy to the indent value?
            if (MessageWindowSize.width - (140.0 * 2)) < self.textFieldTitle.intrinsicContentSize.width {
                constraints.append(NSLayoutConstraint(item: self,
                                                      attribute: .trailing,
                                                      relatedBy: .equal,
                                                      toItem: self.textFieldTitle,
                                                      attribute: .trailing,
                                                      multiplier: 1.0,
                                                      constant: 22.0))
            } else {
                constraints.append(NSLayoutConstraint(item: self,
                                                      attribute: .trailing,
                                                      relatedBy: .equal,
                                                      toItem: self.textFieldTitle,
                                                      attribute: .trailing,
                                                      multiplier: 1.0,
                                                      constant: 97.0))
            }
        }
    }

    private func configureDescription(constraints: inout [NSLayoutConstraint]) {
        guard self.messageDescription != nil else { return }
        self.addSubview(self.textFieldDescription)

        // Top
        constraints.append(NSLayoutConstraint(item:  self.textFieldDescription,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: self.textFieldTitle,
                                              attribute: .bottom,
                                              multiplier: 1.0,
                                              constant: 2.0))

        // Leading
        constraints.append(NSLayoutConstraint(item:  self.textFieldDescription,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self.textFieldTitle,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: 0.0))

        // Trailing
        constraints.append(NSLayoutConstraint(item: self,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: self.textFieldDescription,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: 8.0))
    }

    private func configureIcon(constraints: inout [NSLayoutConstraint]) {
        guard self.messageIcon != nil else { return }
        self.addSubview(self.imageViewIcon)

        // Center Y
        constraints.append(NSLayoutConstraint(item:  self.imageViewIcon,
                                              attribute: .centerY,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .centerY,
                                              multiplier: 1.0,
                                              constant: 0.0))

        // Leading
        constraints.append(NSLayoutConstraint(item:  self.imageViewIcon,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: 20.0))
    }

    // MARK: -
    // MARK: View Setup

    internal func setupTextFieldTitle() {
        self.textFieldTitle.translatesAutoresizingMaskIntoConstraints = false
        self.textFieldTitle.isEditable = false
        self.textFieldTitle.drawsBackground = false
        self.textFieldTitle.isBezeled = false
        self.textFieldTitle.textColor = NSColor.labelColor
        self.textFieldTitle.lineBreakMode = .byTruncatingTail
        self.textFieldTitle.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        self.textFieldTitle.bind(NSBindingName.value,
                                 to: self, withKeyPath: self.messageTitleSelector,
                                 options: [NSBindingOption.continuouslyUpdatesValue: true])
    }

    internal func setupTextFieldDescription() {
        self.textFieldDescription.translatesAutoresizingMaskIntoConstraints = false
        self.textFieldDescription.font = NSFont.modernSystemFont(ofSize: 18, weight: .medium)
        self.textFieldDescription.isEditable = false
        self.textFieldDescription.drawsBackground = false
        self.textFieldDescription.isBezeled = false
        self.textFieldDescription.alignment = .natural
        self.textFieldDescription.textColor = NSColor.secondaryLabelColor
        self.textFieldDescription.lineBreakMode = .byTruncatingTail
        self.textFieldDescription.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        self.textFieldDescription.bind(NSBindingName.value,
                                       to: self, withKeyPath: self.messageDescriptionSelector,
                                       options: [NSBindingOption.continuouslyUpdatesValue: true])
    }

    func setupImageViewIcon(constraints: inout [NSLayoutConstraint]) {
        self.imageViewIcon.translatesAutoresizingMaskIntoConstraints = false
        self.imageViewIcon.imageScaling = .scaleProportionallyUpOrDown
        self.imageViewIcon.setContentHuggingPriority(.required, for: .horizontal)
        self.imageViewIcon.setContentHuggingPriority(.required, for: .vertical)
        self.imageViewIcon.bind(NSBindingName.image,
                                to: self, withKeyPath: self.messageIconSelector,
                                options: [NSBindingOption.continuouslyUpdatesValue: true])

        // Height
        constraints.append(NSLayoutConstraint(item:  self.imageViewIcon,
                                              attribute: .height,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1.0,
                                              constant: 65.0))

        // Width == Height
        constraints.append(NSLayoutConstraint(item:  self.imageViewIcon,
                                              attribute: .width,
                                              relatedBy: .equal,
                                              toItem: self.imageViewIcon,
                                              attribute: .height,
                                              multiplier: 1.0,
                                              constant: 0.0))
    }
}
