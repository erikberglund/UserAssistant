//
//  IsUserLoggingIn.swift
//  UserAssistant
//
//  Created by Erik Berglund on 2018-09-18.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Foundation

func isUserLoggingIn() -> Bool {

    var isUserLoggingIn = false
    let currentUser = NSUserName()

    setutxent_wtmp(0)

    while let wtmpPointer = getutxent_wtmp() {
        var bp = wtmpPointer.pointee

        // Ignore all records that doesn't contain the current user
        let user = withUnsafeBytes(of: &bp.ut_user) { (rawPtr) -> String in
            let ptr = rawPtr.baseAddress!.assumingMemoryBound(to: CChar.self)
            return String(cString: ptr)
        }
        if user != currentUser { continue }

        // Ignore all records that's not a console login
        let line = withUnsafeBytes(of: &bp.ut_line) { (rawPtr) -> String in
            let ptr = rawPtr.baseAddress!.assumingMemoryBound(to: CChar.self)
            return String(cString: ptr)
        }
        if line != "console" { continue }

        // Check that it's a login process
        // If this doesn't match, then noone else will either as it's working backwards chronologically
        if bp.ut_type == Int16(USER_PROCESS) {
            let loginDate = Date(timeIntervalSince1970: TimeInterval(bp.ut_tv.tv_sec))
            isUserLoggingIn = Date().timeIntervalSince(loginDate) < 60
            break
        }
    }

    endutxent_wtmp()

    return isUserLoggingIn
}
