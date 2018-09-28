//
//  ExtensionNSFont.swift
//  UserAssistant
//
//  Created by Erik Berglund on 2018-08-06.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Cocoa

enum FontWeight {
    case light
    case medium
    case regular
    case semibold
    case bold
    case heavy
}

extension NSFont {

    @available(OSX 10.11, *)
    class func fontWeight(forWeight weight: FontWeight) -> NSFont.Weight {
        switch weight {
        case .light:
            return .light
        case .medium:
            return .medium
        case .regular:
            return .regular
        case .semibold:
            return .semibold
        case .bold:
            return .bold
        case .heavy:
            return .heavy
        }
    }

    class func modernSystemFont(ofSize fontSize: CGFloat, weight: FontWeight) -> NSFont {
        if #available(OSX 10.11, *) {
            return NSFont.systemFont(ofSize: fontSize, weight: NSFont.fontWeight(forWeight: weight))
        } else {
            if fontSize < 20.0 {
                switch weight {
                case .light:
                    return NSFont(name: "SFProDisplay-Light", size: fontSize) ?? NSFont.systemFont(ofSize: fontSize)
                case .medium:
                    return NSFont(name: "SFProDisplay-Medium", size: fontSize) ?? NSFont.systemFont(ofSize: fontSize)
                case .regular:
                    return NSFont(name: "SFProDisplay-Regular", size: fontSize) ?? NSFont.systemFont(ofSize: fontSize)
                case .semibold:
                    return NSFont(name: "SFProDisplay-Semibold", size: fontSize) ?? NSFont.systemFont(ofSize: fontSize)
                case .bold:
                    return NSFont(name: "SFProDisplay-Bold", size: fontSize) ?? NSFont.systemFont(ofSize: fontSize)
                case .heavy:
                    return NSFont(name: "SFProDisplay-Heavy", size: fontSize) ?? NSFont.systemFont(ofSize: fontSize)
                }
            } else {
                switch weight {
                case .light:
                    return NSFont(name: "SFProText-Light", size: fontSize) ?? NSFont.systemFont(ofSize: fontSize)
                case .medium:
                    return NSFont(name: "SFProText-Medium", size: fontSize) ?? NSFont.systemFont(ofSize: fontSize)
                case .regular:
                    return NSFont(name: "SFProText-Regular", size: fontSize) ?? NSFont.systemFont(ofSize: fontSize)
                case .semibold:
                    return NSFont(name: "SFProText-Semibold", size: fontSize) ?? NSFont.systemFont(ofSize: fontSize)
                case .bold:
                    return NSFont(name: "SFProText-Bold", size: fontSize) ?? NSFont.systemFont(ofSize: fontSize)
                case .heavy:
                    return NSFont(name: "SFProText-Heavy", size: fontSize) ?? NSFont.systemFont(ofSize: fontSize)
                }
            }
        }
    }
}
