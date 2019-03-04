//
//  MenuItemComputerInfo.swift
//  UserAssistant
//
//  Created by Erik Berglund on 2018-10-09.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Cocoa

class MenuItemComputerInfo: NSMenuItem {
    
    // MARK: -
    // MARK: Initialization
    
    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(title: "Computer Info", action: nil, keyEquivalent: "")
        self.view = MenuItemComputerInfoView()
    }
}

class MenuItemComputerInfoView: NSView {
    
    // MARK: -
    // MARK: Variables
    
    let imageViewComputer = NSImageView()
    let textFieldComputerLabel = NSTextField()
    let textFieldComputerDescription = NSTextField()
    
    @objc private var computerLabel: String = ""
    let computerLabelSelector: String
    
    @objc private var computerDescription: String = ""
    let computerDescriptionSelector: String
    
    var assetViews = [NSView]()
    var assetViewsHeight: CGFloat = kMenuBarMenuItemHeight
    
    // MARK: -
    // MARK: Initialization
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        // ---------------------------------------------------------------------
        //  Setup Selectors
        // ---------------------------------------------------------------------
        self.computerLabelSelector = NSStringFromSelector(#selector(getter: self.computerLabel))
        self.computerDescriptionSelector = NSStringFromSelector(#selector(getter: self.computerDescription))
        
        // ---------------------------------------------------------------------
        //  Initialize Self
        // ---------------------------------------------------------------------
        super.init(frame: NSRect(x: 0, y: 0, width: kMenuBarMenuItemWidht, height: kMenuBarMenuItemHeight))
        
        // ---------------------------------------------------------------------
        //  Setup interface elements
        // ---------------------------------------------------------------------
        var constraints = [NSLayoutConstraint]()
        
        self.setupImageViewComputer(constraints: &constraints)
        self.setupTextFieldComputerLabel(constraints: &constraints)
        self.setupTextFieldComputerDescription(constraints: &constraints)
        
        // ---------------------------------------------------------------------
        //  Activate Layout Constraints
        // ---------------------------------------------------------------------
        NSLayoutConstraint.activate(constraints)
    }
    
    @objc func toggleDescription(sender: NSGestureRecognizer) {
        if #available(OSX 10.12, *) {
            NSAnimationContext.runAnimationGroup { (context) in
                context.duration = 0.25
                context.allowsImplicitAnimation = true
                self.updateAssetViews()
            }
        } else {
            self.updateAssetViews()
        }
    }

    private func updateAssetViews() {
        if self.frame.size.height == kMenuBarMenuItemHeight {
            self.addAssetViews()
            self.setFrameSize(NSSize(width: kMenuBarMenuItemWidht, height: self.assetViewsHeight))
        } else {
            self.resetAssetViews()
        }
    }

    private func assetInfoDict() -> [String: [String: Any]]? {
        guard
            let assetInfoDomain = UserDefaults.standard.string(forKey: AssetInfoKey.domain),
            let assetInfoKeys = UserDefaults.standard.dictionary(forKey: AssetInfoKey.keys) as? [String: [String: String]],
            let assetInfoDefaults = UserDefaults(suiteName: assetInfoDomain) else {
                return nil
        }

        var assetInfoDict = [String: [String: Any]]()

        for (groupKey, groupValue) in assetInfoKeys {
            var groupInfoDict = [String: Any]()
            for (key, value) in groupValue {
                groupInfoDict[key] = assetInfoDefaults.value(forKey: value)
            }
            assetInfoDict[groupKey] = groupInfoDict
        }

        return assetInfoDict
    }

    private func addAssetViews() {

        guard let assetInfoDict = self.assetInfoDict() else {
            return
        }
        
        var constraints = [NSLayoutConstraint]()
        var lastView: NSView?
        
        for groupKey in assetInfoDict.keys.sorted() {

            guard let groupValue = assetInfoDict[groupKey] else {
                continue
            }

            // Group
            let textFieldGroup = self.assetLabelTextField(withTitle: groupKey)
            textFieldGroup.textColor = .labelColor
            textFieldGroup.font = .modernSystemFont(ofSize: 14.0, weight: .bold)
            self.setupAssetGroup(textFieldGroup, below: lastView, constraints: &constraints)
            self.assetViews.append(textFieldGroup)

            let textFieldGroupSeparator = self.setupAssetGroupSeparator(below: textFieldGroup, constraints: &constraints)
            self.assetViews.append(textFieldGroupSeparator)
            lastView = textFieldGroupSeparator

            for key in groupValue.keys.sorted() {

                guard let value = groupValue[key] else {
                    continue
                }

                // Key
                let textFieldKey = self.assetLabelTextField(withTitle: key)
                textFieldKey.stringValue = textFieldKey.stringValue + ":"
                self.setupAssetLabelKey(textFieldKey, below: lastView, constraints: &constraints)
                self.assetViews.append(textFieldKey)
                lastView = textFieldKey
                
                // Value
                let valueString = String(describing: value)
                let textFieldValue = self.assetLabelTextField(withTitle: valueString)
                self.setupAssetLabelValue(textFieldValue, forKey: textFieldKey, constraints: &constraints)
                self.assetViews.append(textFieldValue)
            }
        }
        
        // ---------------------------------------------------------------------
        //  Activate Layout Constraints
        // ---------------------------------------------------------------------
        NSLayoutConstraint.activate(constraints)
    }

    private func resetAssetViews() {
        self.setFrameSize(NSSize(width: kMenuBarMenuItemWidht, height: kMenuBarMenuItemHeight))
        for textField in self.assetViews {
            textField.removeFromSuperview()
        }
        self.assetViews = [NSTextField]()
        self.assetViewsHeight = kMenuBarMenuItemHeight
    }
    
    private func setupAssetLabelKey(_ textField: NSTextField, below: NSView?, constraints: inout [NSLayoutConstraint]) {

        let spacingTop: CGFloat = 2.0

        textField.textColor = .secondaryLabelColor
        textField.setContentCompressionResistancePriority(.required, for: .horizontal)
        textField.setContentCompressionResistancePriority(.required, for: .vertical)

        self.assetViewsHeight += spacingTop
        self.assetViewsHeight += textField.intrinsicContentSize.height
        
        self.addSubview(textField)
        
        // Top
        constraints.append(NSLayoutConstraint(item: textField,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: below ?? self.textFieldComputerDescription,
                                              attribute: .bottom,
                                              multiplier: 1.0,
                                              constant: spacingTop))
        
        // Leading
        constraints.append(NSLayoutConstraint(item: textField,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: below ?? self.textFieldComputerDescription,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: below is NSBox ? 16.0 : 0.0))
    }
    
    private func setupAssetLabelValue(_ textField: NSTextField, forKey: NSTextField, constraints: inout [NSLayoutConstraint]) {

        textField.lineBreakMode = .byTruncatingMiddle

        self.addSubview(textField)
        
        // Baseline
        constraints.append(NSLayoutConstraint(item: textField,
                                              attribute: .centerY,
                                              relatedBy: .equal,
                                              toItem: forKey,
                                              attribute: .centerY,
                                              multiplier: 1.0,
                                              constant: 0.0))
        
        // Leading
        constraints.append(NSLayoutConstraint(item: textField,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: forKey,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: 4.0))
        
        // Trailing
        constraints.append(NSLayoutConstraint(item: self,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: textField,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: 8.0))
    }

    private func setupAssetGroup(_ textField: NSTextField, below: NSView?, constraints: inout [NSLayoutConstraint]) {
        self.addSubview(textField)

        let spacingTop: CGFloat = 2.0

        self.assetViewsHeight += spacingTop
        self.assetViewsHeight += textField.intrinsicContentSize.height

        self.addSubview(textField)

        // Top
        constraints.append(NSLayoutConstraint(item: textField,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: below ?? self.textFieldComputerDescription,
                                              attribute: .bottom,
                                              multiplier: 1.0,
                                              constant: spacingTop))

        // Leading
        constraints.append(NSLayoutConstraint(item: textField,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self.textFieldComputerDescription,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: 0.0))
    }

    private func setupAssetGroupSeparator(below: NSTextField, constraints: inout [NSLayoutConstraint]) -> NSView {

        let separator = NSBox(frame: NSRect(x: 1.0, y: 1.0, width: 1.0, height: 1.0))
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.boxType = .separator
        self.addSubview(separator)
        self.assetViews.append(separator)

        let separatorSpacingTop: CGFloat = 2.0

        self.assetViewsHeight += separatorSpacingTop
        self.assetViewsHeight += separator.intrinsicContentSize.height

        // Top
        constraints.append(NSLayoutConstraint(item: separator,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: below,
                                              attribute: .bottom,
                                              multiplier: 1.0,
                                              constant: separatorSpacingTop))

        // Leading
        constraints.append(NSLayoutConstraint(item: separator,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: below,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: 0.0))

        // Trailing
        constraints.append(NSLayoutConstraint(item: self,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: separator,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: 8.0))

        return separator

    }

    private func assetLabelTextField(withTitle title: String) -> NSTextField {
        let textField = NSTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isEditable = false
        textField.isBordered = false
        textField.isBezeled = false
        textField.drawsBackground = false
        textField.textColor = .secondaryLabelColor
        textField.font = .modernSystemFont(ofSize: 14.0, weight: .regular)
        textField.stringValue = title
        return textField
    }
    
    // MARK: -
    // MARK:
    
    private func setupImageViewComputer(constraints: inout [NSLayoutConstraint]) {
        self.imageViewComputer.translatesAutoresizingMaskIntoConstraints = false
        self.imageViewComputer.image = NSImage(named: NSImage.computerName)
        self.imageViewComputer.imageScaling = .scaleProportionallyUpOrDown
        self.addSubview(self.imageViewComputer)
        
        // Top
        constraints.append(NSLayoutConstraint(item: self,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: self.imageViewComputer,
                                              attribute: .top,
                                              multiplier: 1.0,
                                              constant: 12.0))
        
        // Leading
        constraints.append(NSLayoutConstraint(item: self.imageViewComputer,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: 6.0))
        
        // Height
        constraints.append(NSLayoutConstraint(item: self.imageViewComputer,
                                              attribute: .height,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1.0,
                                              constant: 70.0))
        // Width == Height
        constraints.append(NSLayoutConstraint(item: self.imageViewComputer,
                                              attribute: .height,
                                              relatedBy: .equal,
                                              toItem: self.imageViewComputer,
                                              attribute: .width,
                                              multiplier: 1.0,
                                              constant: 0.0))
    }
    
    private func setupTextFieldComputerLabel(constraints: inout [NSLayoutConstraint]) {
        self.textFieldComputerLabel.translatesAutoresizingMaskIntoConstraints = false
        self.textFieldComputerLabel.isEditable = false
        self.textFieldComputerLabel.isBordered = false
        self.textFieldComputerLabel.isBezeled = false
        self.textFieldComputerLabel.drawsBackground = false
        self.textFieldComputerLabel.lineBreakMode = .byTruncatingTail
        self.textFieldComputerLabel.font = .modernSystemFont(ofSize: 17.0, weight: .bold)
        self.addSubview(self.textFieldComputerLabel)
        
        // Bind
        self.textFieldComputerLabel.bind(.value, to: self, withKeyPath: self.computerLabelSelector, options: [.continuouslyUpdatesValue: true])
        
        // Top
        constraints.append(NSLayoutConstraint(item: self.textFieldComputerLabel,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .top,
                                              multiplier: 1.0,
                                              constant: 6.0))
        
        // Leading
        constraints.append(NSLayoutConstraint(item: self.textFieldComputerLabel,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self.imageViewComputer,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: 6.0))
        
        // Trailing
        constraints.append(NSLayoutConstraint(item: self,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: self.textFieldComputerLabel,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: 6.0))
    }
    
    private func setupTextFieldComputerDescription(constraints: inout [NSLayoutConstraint]) {
        self.textFieldComputerDescription.translatesAutoresizingMaskIntoConstraints = false
        self.textFieldComputerDescription.isEditable = false
        self.textFieldComputerDescription.isBordered = false
        self.textFieldComputerDescription.isBezeled = false
        self.textFieldComputerDescription.drawsBackground = false
        self.textFieldComputerDescription.lineBreakMode = .byTruncatingTail
        self.textFieldComputerDescription.textColor = .secondaryLabelColor
        self.textFieldComputerDescription.font = .modernSystemFont(ofSize: 14.0, weight: .regular)
        self.addSubview(self.textFieldComputerDescription)
        
        // Bind
        self.textFieldComputerDescription.bind(.value, to: self, withKeyPath: self.computerDescriptionSelector, options: [.continuouslyUpdatesValue: true])
        
        // ---------------------------------------------------------------------
        //  Setup GestureRecognizer
        // ---------------------------------------------------------------------
        let gesture = NSClickGestureRecognizer()
        gesture.numberOfClicksRequired = 1
        gesture.target = self
        gesture.action = #selector(self.toggleDescription(sender:))
        self.textFieldComputerDescription.addGestureRecognizer(gesture)
        
        // Top
        constraints.append(NSLayoutConstraint(item: self.textFieldComputerDescription,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: self.textFieldComputerLabel,
                                              attribute: .bottom,
                                              multiplier: 1.0,
                                              constant: 0.0))
        
        // Leading
        constraints.append(NSLayoutConstraint(item: self.textFieldComputerDescription,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self.imageViewComputer,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: 6.0))
        
        // Trailing
        constraints.append(NSLayoutConstraint(item: self,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: self.textFieldComputerDescription,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: 6.0))
    }
    
    override func viewWillMove(toWindow newWindow: NSWindow?) {
        if newWindow == nil {
            self.resetAssetViews()
        } else {
            
            // Name
            self.setValue(AssetInfo.shared.assetTag, forKey: self.computerLabelSelector)
            
            // Model Name
            HardwareInfo.shared.getMachineModelName { name in
                self.setValue(name, forKey: self.computerDescriptionSelector)
            }
        }
    }
}
