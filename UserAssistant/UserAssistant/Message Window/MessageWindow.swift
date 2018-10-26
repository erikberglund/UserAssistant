//
//  MessageWindow.swift
//  UserAssistant
//
//  Created by Erik Berglund on 2018-08-06.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Cocoa
import WebKit

class MessageWindow: NSWindow, MessageWindowNavigationDelegate {

    // MARK: -
    // MARK: Variables

    let headerView = MessageWindowHeaderView()
    let headerSeparator = NSBox(frame: NSRect.zero)
    let bodyView = MessageWindowBodyView()
    let contactView = MessageWindowContactView()
    let buttonView = MessageWindowButtonView()

    var bodyWebView: MessageWindowBodyWebView?
    lazy var bodyApplication = MessageWindowBodyApplication()

    var currentAction: Action?

    var backgroundWindows = [NSWindow]()

    // MARK: -
    // MARK: Initialization

    init() {

        if let contentRect = MessageWindow.contentRect() {
            super.init(contentRect: contentRect, styleMask: .unifiedTitleAndToolbar, backing: .buffered, defer: false)
            self.contentMinSize = contentRect.size
            self.titleVisibility = .hidden
        } else {
            super.init()
        }

        self.level = NSWindow.Level(rawValue: NSWindow.Level.screenSaver.rawValue - 1)
        self.canBecomeVisibleWithoutLogin = true
        self.backgroundColor = .white
        self.isReleasedWhenClosed = false

        self.bodyWebView = MessageWindowBodyWebView(withNavigationDelegate: self)

        var constraints = [NSLayoutConstraint]()

        self.setupHeaderView(constraints: &constraints)
        self.setupHeaderSeparator(constraints: &constraints)

        NSLayoutConstraint.activate(constraints)
    }

    class func contentRect() -> NSRect? {
        return self.contentRect(width: MessageWindowSize.width, height: MessageWindowSize.height)
    }

    class func contentRect(width: CGFloat, height: CGFloat) -> NSRect? {
        guard let screenSize = NSScreen.main?.frame.size else { return nil }
        let windowSize = NSSize(width: width, height: height)
        let centerX = (screenSize.width - windowSize.width) / 2.0
        let centerY = (screenSize.height - windowSize.height) / 2.0
        return NSRect.init(x: centerX, y: centerY, width: windowSize.width, height: windowSize.height)
    }

    private func removeSubviews() {
        self.bodyView.removeFromSuperview()
        self.contactView.removeFromSuperview()
        self.buttonView.removeFromSuperview()
    }

    func show(forAction action: Action) {

        // ---------------------------------------------------------------------
        //  Update the current action
        // ---------------------------------------------------------------------
        self.currentAction = action

        // ---------------------------------------------------------------------
        //  Configure Window
        // ---------------------------------------------------------------------
        self.setupWindow(action: action)

        // ---------------------------------------------------------------------
        //  Configure Header
        // ---------------------------------------------------------------------
        self.headerView.setupHeader(withTitle: localizedString(for: action.messageTitle),
                                    description: localizedString(for: action.messageDescription),
                                    icon: action.icon,
                                    showBackground: action.showHeaderBackgroundColor)

        // ---------------------------------------------------------------------
        //  Remove existing body content
        // ---------------------------------------------------------------------
        self.removeSubviews()
        var constraints = [NSLayoutConstraint]()

        // ---------------------------------------------------------------------
        //  Configure Buttons
        // ---------------------------------------------------------------------
        self.setupButtonView(constraints: &constraints)
        self.buttonView.setupButtons(withButtonConfiguration: action.buttonConfiguration)

        // ---------------------------------------------------------------------
        //  Configure Contact Information
        // ---------------------------------------------------------------------
        self.setupContactView(constraints: &constraints)
        self.contactView.setupContact(withMessage: localizedString(for: action.contactMessage), methods: action.contactMethods)

        // ---------------------------------------------------------------------
        //  Configure Body Information
        // ---------------------------------------------------------------------
        let message = localizedString(for: action.message)
        if action.type == .applicationBlock || action.type == .applicationWarn {
            if let application = action.applications.first {
                self.setupBodyApplication(constraints: &constraints)
                NSLayoutConstraint.activate(constraints)
                self.bodyApplication.setupMessage(message, application: application)
                self.orderFront() // FIXME: Move this maybe?
            }
        } else if !message.isEmpty {
            if message.hasPrefix("<html>") {
                self.setupBodyWebView(constraints: &constraints)
                NSLayoutConstraint.activate(constraints)
                self.bodyWebView?.loadHTMLString(message, fullSizeContent: action.messageFullSizeContent)
            } else {
                self.setupBodyView(constraints: &constraints)
                NSLayoutConstraint.activate(constraints)
                self.bodyView.setupMessage(message)
                self.orderFront() // FIXME: Move this maybe?
            }
        } else if let actionURL = action.messageURL {
            self.setupBodyWebView(constraints: &constraints)
            NSLayoutConstraint.activate(constraints)
            self.bodyWebView?.loadURL(actionURL, fullSizeContent: action.messageFullSizeContent)
        }
    }

    override func close() {
        guard let currentAction = self.currentAction else {
            self.hideBackground()
            super.close()
            return
        }

        if !currentAction.applications.isEmpty {
            currentAction.applications.remove(at: 0)
            if !currentAction.applications.isEmpty {
                self.show(forAction: currentAction)
                return
            }
        }

        Actions.shared.actionsQueued.remove(at: 0)
        if !Actions.shared.actionsQueued.isEmpty {
            Actions.shared.queueShowNext()
        } else {
            self.hideBackground()
            super.close()
        }
    }

    private func setupWindow(action: Action) {
        let windowWidth = action.windowWidth ?? MessageWindowSize.width
        let windowHeight = action.windowHeight ?? MessageWindowSize.height
        guard let contentRect = MessageWindow.contentRect(width: windowWidth, height: windowHeight) else { return }
        if contentRect != self.frame {
            self.setFrame(contentRect, display: true)
        }
    }

    func orderFront() {
        if self.backgroundWindows.isEmpty {
            self.showBackground()
        }
        NSApplication.shared.activate(ignoringOtherApps: true)
        self.makeKeyAndOrderFront(self)
        self.orderFrontRegardless()
    }

    func showBackground() {
        self.backgroundWindows.removeAll()

        for screen in NSScreen.screens {

            let view = NSVisualEffectView()
            view.blendingMode = .behindWindow
            view.material = .dark
            view.state = .active

            let window = NSWindow(contentRect: screen.frame,
                                  styleMask: .fullSizeContentView,
                                  backing: .buffered,
                                  defer: true)
            window.isReleasedWhenClosed = false
            window.backgroundColor = .white
            window.contentView = view
            window.level = NSWindow.Level(rawValue: self.level.rawValue - 1)
            window.orderFrontRegardless()
            self.backgroundWindows.append(window)
        }
    }

    func hideBackground() {
        for window in self.backgroundWindows {
            window.close()
        }
        self.backgroundWindows.removeAll()
    }

    // MARK: -
    // MARK: MessageWindowNavigationDelegate Methods

    func navigationFailed(withError error: Error) {
        Swift.print("navigationFailed withError: \(error)")
    }

    func navigationComplete() {
        self.orderFront()
    }

    // MARK: -
    // MARK: NSWindow Methods

    override var canBecomeKey: Bool { return true }
    override var canBecomeMain: Bool { return true }

    override func constrainFrameRect(_ frameRect: NSRect, to screen: NSScreen?) -> NSRect {
        return super.constrainFrameRect(frameRect, to: NSScreen.main)
    }

    // MARK: -
    // MARK: View Setup

    private func setupViewLeading(_ view: NSView, toContentView contentView: NSView, constraints: inout [NSLayoutConstraint]) {
        constraints.append(NSLayoutConstraint(item:  view,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: contentView,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: 0.0))
    }

    private func setupViewTrailing(_ view: NSView, toContentView contentView: NSView, constraints: inout [NSLayoutConstraint]) {
        constraints.append(NSLayoutConstraint(item:  view,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: contentView,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: 0.0))
    }

    private func setupHeaderView(constraints: inout [NSLayoutConstraint]) {
        guard let contentView = self.contentView else { return }
        contentView.addSubview(self.headerView)

        // Top
        constraints.append(NSLayoutConstraint(item:  self.headerView,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: contentView,
                                              attribute: .top,
                                              multiplier: 1.0,
                                              constant: 0.0))

        // Leading
        self.setupViewLeading(self.headerView, toContentView: contentView, constraints: &constraints)

        // Trailing
        self.setupViewTrailing(self.headerView, toContentView: contentView, constraints: &constraints)

        // Height
        constraints.append(NSLayoutConstraint(item:  self.headerView,
                                              attribute: .height,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1.0,
                                              constant: 100.0))
    }

    private func setupHeaderSeparator(constraints: inout [NSLayoutConstraint]) {
        guard let contentView = self.contentView else { return }
        self.headerSeparator.translatesAutoresizingMaskIntoConstraints = false
        self.headerSeparator.boxType = .separator
        contentView.addSubview(self.headerSeparator)

        // Top
        constraints.append(NSLayoutConstraint(item:  self.headerSeparator,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: self.headerView,
                                              attribute: .bottom,
                                              multiplier: 1.0,
                                              constant: 0.0))

        // Leading
        self.setupViewLeading(self.headerSeparator, toContentView: contentView, constraints: &constraints)

        // Trailing
        self.setupViewTrailing(self.headerSeparator, toContentView: contentView, constraints: &constraints)
    }

    private func setupBodyView(constraints: inout [NSLayoutConstraint]) {
        guard let contentView = self.contentView else { return }
        contentView.addSubview(self.bodyView)

        // Top
        constraints.append(NSLayoutConstraint(item:  self.headerSeparator,
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: self.bodyView,
                                              attribute: .top,
                                              multiplier: 1.0,
                                              constant: 0.0))

        // Bottom
        if contentView.subviews.contains(self.contactView) {
            constraints.append(NSLayoutConstraint(item:  self.contactView,
                                                  attribute: .top,
                                                  relatedBy: .equal,
                                                  toItem: self.bodyView,
                                                  attribute: .bottom,
                                                  multiplier: 1.0,
                                                  constant: 0.0))
        } else if contentView.subviews.contains(self.buttonView) {
            constraints.append(NSLayoutConstraint(item:  self.buttonView,
                                                  attribute: .top,
                                                  relatedBy: .equal,
                                                  toItem: self.bodyView,
                                                  attribute: .bottom,
                                                  multiplier: 1.0,
                                                  constant: 0.0))
        } else {
            constraints.append(NSLayoutConstraint(item:  contentView,
                                                  attribute: .bottom,
                                                  relatedBy: .equal,
                                                  toItem: self.bodyView,
                                                  attribute: .bottom,
                                                  multiplier: 1.0,
                                                  constant: 0.0))
        }

        // Leading
        self.setupViewLeading(self.bodyView, toContentView: contentView, constraints: &constraints)

        // Trailing
        self.setupViewTrailing(self.bodyView, toContentView: contentView, constraints: &constraints)
    }

    private func setupBodyApplication(constraints: inout [NSLayoutConstraint]) {
        guard let contentView = self.contentView else { return }
        contentView.addSubview(self.bodyApplication)

        // Top
        constraints.append(NSLayoutConstraint(item:  self.headerSeparator,
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: self.bodyApplication,
                                              attribute: .top,
                                              multiplier: 1.0,
                                              constant: 0.0))

        // Bottom
        if contentView.subviews.contains(self.contactView) {
            constraints.append(NSLayoutConstraint(item:  self.contactView,
                                                  attribute: .top,
                                                  relatedBy: .equal,
                                                  toItem: self.bodyApplication,
                                                  attribute: .bottom,
                                                  multiplier: 1.0,
                                                  constant: 0.0))
        } else if contentView.subviews.contains(self.buttonView) {
            constraints.append(NSLayoutConstraint(item:  self.buttonView,
                                                  attribute: .top,
                                                  relatedBy: .equal,
                                                  toItem: self.bodyApplication,
                                                  attribute: .bottom,
                                                  multiplier: 1.0,
                                                  constant: 0.0))
        } else {
            constraints.append(NSLayoutConstraint(item:  contentView,
                                                  attribute: .bottom,
                                                  relatedBy: .equal,
                                                  toItem: self.bodyApplication,
                                                  attribute: .bottom,
                                                  multiplier: 1.0,
                                                  constant: 0.0))
        }

        // Leading
        self.setupViewLeading(self.bodyApplication, toContentView: contentView, constraints: &constraints)

        // Trailing
        self.setupViewTrailing(self.bodyApplication, toContentView: contentView, constraints: &constraints)
    }

    private func setupBodyWebView(constraints: inout [NSLayoutConstraint]) {
        guard let contentView = self.contentView, let bodyWebView = self.bodyWebView else { return }
        contentView.addSubview(bodyWebView)

        // Top
        constraints.append(NSLayoutConstraint(item:  self.headerSeparator,
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: bodyWebView,
                                              attribute: .top,
                                              multiplier: 1.0,
                                              constant: 0.0))

        // Bottom
        if contentView.subviews.contains(self.contactView) {
            constraints.append(NSLayoutConstraint(item:  self.contactView,
                                                  attribute: .top,
                                                  relatedBy: .equal,
                                                  toItem: bodyWebView,
                                                  attribute: .bottom,
                                                  multiplier: 1.0,
                                                  constant: 0.0))
        } else if contentView.subviews.contains(self.buttonView) {
            constraints.append(NSLayoutConstraint(item:  self.buttonView,
                                                  attribute: .top,
                                                  relatedBy: .equal,
                                                  toItem: bodyWebView,
                                                  attribute: .bottom,
                                                  multiplier: 1.0,
                                                  constant: 0.0))
        } else {
            constraints.append(NSLayoutConstraint(item:  contentView,
                                                  attribute: .bottom,
                                                  relatedBy: .equal,
                                                  toItem: bodyWebView,
                                                  attribute: .bottom,
                                                  multiplier: 1.0,
                                                  constant: 0.0))
        }

        // Leading
        self.setupViewLeading(bodyWebView, toContentView: contentView, constraints: &constraints)

        // Trailing
        self.setupViewTrailing(bodyWebView, toContentView: contentView, constraints: &constraints)
    }

    private func setupContactView(constraints: inout [NSLayoutConstraint]) {
        guard let contentView = self.contentView else { return }
        contentView.addSubview(self.contactView)

        // Bottom
        if contentView.subviews.contains(self.buttonView) {
            constraints.append(NSLayoutConstraint(item: self.buttonView,
                                                  attribute: .top,
                                                  relatedBy: .equal,
                                                  toItem: self.contactView,
                                                  attribute: .bottom,
                                                  multiplier: 1.0,
                                                  constant: 0.0))
        } else {
            constraints.append(NSLayoutConstraint(item: contentView,
                                                  attribute: .bottom,
                                                  relatedBy: .equal,
                                                  toItem: self.contactView,
                                                  attribute: .bottom,
                                                  multiplier: 1.0,
                                                  constant: 0.0))
        }

        // Leading
        self.setupViewLeading(self.contactView, toContentView: contentView, constraints: &constraints)

        // Trailing
        self.setupViewTrailing(self.contactView, toContentView: contentView, constraints: &constraints)
    }

    private func setupButtonView(constraints: inout [NSLayoutConstraint]) {
        guard let contentView = self.contentView else { return }
        contentView.addSubview(self.buttonView)

        // Bottom
        constraints.append(NSLayoutConstraint(item:  contentView,
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: self.buttonView,
                                              attribute: .bottom,
                                              multiplier: 1.0,
                                              constant: 0.0))

        // Leading
        self.setupViewLeading(self.buttonView, toContentView: contentView, constraints: &constraints)

        // Trailing
        self.setupViewTrailing(self.buttonView, toContentView: contentView, constraints: &constraints)

        // Height
        constraints.append(NSLayoutConstraint(item:  self.buttonView,
                                              attribute: .height,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1.0,
                                              constant: 50.0))
    }
}
