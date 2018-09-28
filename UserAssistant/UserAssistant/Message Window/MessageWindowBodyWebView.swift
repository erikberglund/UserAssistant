//
//  MessageWindowBody.swift
//  UserAssistant
//
//  Created by Erik Berglund on 2018-08-06.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Cocoa
import WebKit

protocol MessageWindowNavigationDelegate {
    func navigationFailed(withError: Error)
    func navigationComplete()
}

class MessageWindowBodyWebView: NSView {

    private let webViewMessage = WKWebView()

    private var constraintTop: NSLayoutConstraint?
    private var constraintBottom: NSLayoutConstraint?
    private var constraintLeading: NSLayoutConstraint?
    private var constraintTrailing: NSLayoutConstraint?

    private var navigationDelegate: MessageWindowNavigationDelegate?

    // MARK: -
    // MARK: Intialization

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(withNavigationDelegate delegate: MessageWindowNavigationDelegate) {

        // ---------------------------------------------------------------------
        //  Set the passed navigation delegate
        // ---------------------------------------------------------------------
        self.navigationDelegate = delegate

        // ---------------------------------------------------------------------
        //  Initialize Self
        // ---------------------------------------------------------------------
        super.init(frame: NSRect.zero)

        // ---------------------------------------------------------------------
        //  Setup interface elements
        // ---------------------------------------------------------------------
        var constraints = [NSLayoutConstraint]()

        self.translatesAutoresizingMaskIntoConstraints = false
        self.setupWebViewMessage(constraints: &constraints)

        // ---------------------------------------------------------------------
        //  Activate Layout Constraints
        // ---------------------------------------------------------------------
        NSLayoutConstraint.activate(constraints)
    }

    // MARK: -
    // MARK: MessageWindowBodyView Methods

    func loadHTMLString(_ htmlString: String?, fullSizeContent: Bool) {

        // ---------------------------------------------------------------------
        //  Update the constraints if the content should be full size or not
        // ---------------------------------------------------------------------
        self.updateConstraints(fullSizeContent: fullSizeContent)

        // ---------------------------------------------------------------------
        //  Update the webview with the html string
        // ---------------------------------------------------------------------
        self.webViewMessage.loadHTMLString(htmlString ?? "", baseURL: nil)
    }

    func loadURL(_ urlString: String, fullSizeContent: Bool) {

        // ---------------------------------------------------------------------
        //  Update the constraints if the content should be full size or not
        // ---------------------------------------------------------------------
        self.updateConstraints(fullSizeContent: fullSizeContent)

        // ---------------------------------------------------------------------
        //  Update the webview by loading the URL
        // ---------------------------------------------------------------------
        guard let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url)
        self.webViewMessage.load(request)
    }

    func updateConstraints(fullSizeContent fullSize: Bool) {
        if fullSize {
            self.constraintTop?.constant = 0.0
            self.constraintBottom?.constant = 0.0
            self.constraintLeading?.constant = 0.0
            self.constraintTrailing?.constant = 0.0
        } else {
            self.constraintTop?.constant = 22.0
            self.constraintBottom?.constant = 0.0
            self.constraintLeading?.constant = 55.0
            self.constraintTrailing?.constant = 55.0
        }
    }

    // MARK: -
    // MARK: View Setup

    internal func setupWebViewMessage(constraints: inout [NSLayoutConstraint]) {
        self.webViewMessage.translatesAutoresizingMaskIntoConstraints = false
        self.webViewMessage.navigationDelegate = self
        self.addSubview(self.webViewMessage)

        // Top
        self.constraintTop = NSLayoutConstraint(item: self.webViewMessage,
                                                attribute: .top,
                                                relatedBy: .equal,
                                                toItem: self,
                                                attribute: .top,
                                                multiplier: 1.0,
                                                constant: 22.0)
        constraints.append(self.constraintTop!)

        // Bottom
        self.constraintBottom = NSLayoutConstraint(item: self,
                                                   attribute: .bottom,
                                                   relatedBy: .equal,
                                                   toItem: self.webViewMessage,
                                                   attribute: .bottom,
                                                   multiplier: 1.0,
                                                   constant: 0.0)
        constraints.append(self.constraintBottom!)

        // Leading
        self.constraintLeading = NSLayoutConstraint(item: self.webViewMessage,
                                                    attribute: .leading,
                                                    relatedBy: .equal,
                                                    toItem: self,
                                                    attribute: .leading,
                                                    multiplier: 1.0,
                                                    constant: 55.0)
        constraints.append(self.constraintLeading!)

        // Trailing
        self.constraintTrailing = NSLayoutConstraint(item: self,
                                                     attribute: .trailing,
                                                     relatedBy: .equal,
                                                     toItem: self.webViewMessage,
                                                     attribute: .trailing,
                                                     multiplier: 1.0,
                                                     constant: 55.0)
        constraints.append(self.constraintTrailing!)
    }
}

extension MessageWindowBodyWebView: WKNavigationDelegate {

    // Disable the right-click context menu
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.getElementsByTagName('body')[0].setAttribute('oncontextmenu', 'event.preventDefault();');", completionHandler: nil)
        guard let navigationDelegate = self.navigationDelegate else { return }
        navigationDelegate.navigationComplete()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        navigationDelegate?.navigationFailed(withError: error)
    }
}
