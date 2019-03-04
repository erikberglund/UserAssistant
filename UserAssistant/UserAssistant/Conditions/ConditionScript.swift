//
//  ConditionScript.swift
//  UserAssistant
//
//  Created by Erik Berglund on 2018-08-30.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Foundation

extension ConditionItem {
    func verifyScript(completionHandler: @escaping (_ conditionStatus: ConditionStatus, _ error: String?) -> Void) {
        guard let script = self.script else {
            completionHandler(.failed, nil)
            return
        }

        runScript(script) { (stdOut, stdErr, exitCode) in
            Swift.print("Script stdOut: \(String(describing: stdOut))")
            Swift.print("Script stdErr: \(String(describing: stdErr))")
            Swift.print("Script exitCode: \(exitCode)")
            if exitCode == 0 {
                if let stdOutString = stdOut, stdOutString.contains("true") {
                    completionHandler(.pass, nil)
                    return
                }
            } else {
                Swift.print("Script failed with exit code: \(exitCode)")
            }
            completionHandler(.failed, nil)
        }
    }
}
