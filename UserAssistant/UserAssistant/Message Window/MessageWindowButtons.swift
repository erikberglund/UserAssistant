//
//  MessageWindowButtons.swift
//  UserAssistant
//
//  Created by Erik Berglund on 2018-08-08.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Cocoa

class MessageWindowButtonView: NSView {

    private var buttons = [NSButton]()
    private var buttonsWidth: CGFloat = 0
    private var buttonsInfo = [String: Any]()
    private let buttonsDefault = [[ ButtonKey.title: "OK", ButtonKey.isDefault: true ]]

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

        self.translatesAutoresizingMaskIntoConstraints = false
    }

    // MARK: -
    // MARK: Button Actions

    @objc func buttonClicked(_ button: NSButton) {
        guard let window = self.window as? MessageWindow else { return }
        guard let buttonIdentifier = button.identifier?.rawValue else { return }
        guard let buttonConfiguration = self.buttonsInfo[buttonIdentifier] as? [String: Any] else { return }

        self.activate(buttonConfiguration: buttonConfiguration, action: window.currentAction)

        window.close()
    }

    func activate(buttonConfiguration: [String: Any], action: Action?) {

        // Link
        if
            let urlString = buttonConfiguration[ButtonKey.link] as? String,
            let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }

        // Path
        if let pathString = buttonConfiguration[ButtonKey.path] as? String {
            NSWorkspace.shared.openFile(pathString)
        }

        // Script
        if let script = buttonConfiguration[ButtonKey.script] as? String {
            runScript(script) { (stdOut, stdErr, exitCode) in
                Swift.print("Script stdOut: \(stdOut)")
                Swift.print("Script stdErr: \(stdErr)")
                Swift.print("Script exitCode: \(exitCode)")
            }
        }
    }

    // MARK: -
    // MARK: MessageWindowButtonView Methods

    func setupButtons(withButtonConfiguration: [[String: Any]]?) {
        self.removeSubviews()
        self.buttons.removeAll()
        self.buttonsInfo.removeAll()
        self.buttonsWidth = 0

        let buttonConfigurations = withButtonConfiguration ?? self.buttonsDefault

        var constraints = [NSLayoutConstraint]()

        var previousButton: NSButton?
        for buttonConfig in buttonConfigurations {
            let identifier = UUID().uuidString
            let button = self.addButton(withTitle: buttonConfig[ButtonKey.title] as? String,
                                        identifier: identifier,
                                        isDefault: buttonConfig[ButtonKey.isDefault] as? Bool ?? false,
                                        previousButton: previousButton,
                                        constraints: &constraints)
            previousButton = button
            self.buttonsInfo[identifier] = buttonConfig
            self.buttons.append(button)
        }

        // Trailing
        if let lastButton = previousButton {
            constraints.append(NSLayoutConstraint(item: lastButton,
                                                  attribute: .trailing,
                                                  relatedBy: .equal,
                                                  toItem: self,
                                                  attribute: .centerX,
                                                  multiplier: 1.0,
                                                  constant: (self.buttonsWidth / 2.0)))
        }

        // ---------------------------------------------------------------------
        //  Activate Layout Constraints
        // ---------------------------------------------------------------------
        NSLayoutConstraint.activate(constraints)
    }

    internal func addButton(withTitle title: String?, identifier: String, isDefault: Bool, previousButton: NSButton?, constraints: inout [NSLayoutConstraint]) -> NSButton {

        let button = NSButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonType(.momentaryPushIn)
        button.bezelStyle = .rounded
        button.isBordered = true
        button.title = title ?? NSLocalizedString("OK", comment: "")
        button.target = self
        button.action = #selector(self.buttonClicked(_:))
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        button.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        button.identifier = NSUserInterfaceItemIdentifier(rawValue: identifier)
        if isDefault { button.keyEquivalent = "\r" }

        self.addSubview(button)
        button.sizeToFit()

        self.buttonsWidth += button.intrinsicContentSize.width

        // Leading
        if let leadingButton = previousButton {
            constraints.append(NSLayoutConstraint(item: button,
                                                  attribute: .leading,
                                                  relatedBy: .equal,
                                                  toItem: leadingButton,
                                                  attribute: .trailing,
                                                  multiplier: 1.0,
                                                  constant: 10.0))
            self.buttonsWidth = self.buttonsWidth + 10.0
        }

        // Center Y
        constraints.append(NSLayoutConstraint(item: self,
                                              attribute: .centerY,
                                              relatedBy: .equal,
                                              toItem: button,
                                              attribute: .centerY,
                                              multiplier: 1.0,
                                              constant: 13.0))

        return button
    }
}

