//
//  AppProtocol.swift
//  UserAssistant
//
//  Created by Erik Berglund.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Foundation

@objc(AppProtocol)
protocol AppProtocol {
    func log(stdOut: String) -> Void
    func log(stdErr: String) -> Void
}
