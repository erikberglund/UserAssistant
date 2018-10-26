//
//  Identity.swift
//  UserAssistant
//
//  Created by Erik Berglund on 2018-10-11.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Foundation
import Collaboration

let kGIDAdmin: gid_t = 80

enum IdentityError: Error {
    case message(String)
}

class Identity {

    static func csIdentityForUser(_ username: String) throws -> CSIdentity? {
        guard let authority = CSGetLocalIdentityAuthority()?.takeUnretainedValue() else {
            throw IdentityError.message("Failed to get Local Identity Authority")
        }

        guard let query = CSIdentityQueryCreateForName(kCFAllocatorDefault,
                                                       username as CFString,
                                                       kCSIdentityQueryStringEquals,
                                                       kCSIdentityClassUser,
                                                       authority)?.takeRetainedValue() else {
                                                        throw IdentityError.message("Failed to create query for username: \(username)")
        }

        var error: Unmanaged<CFError>? = nil
        guard CSIdentityQueryExecute(query, CSIdentityQueryFlags(kCSIdentityQueryGenerateUpdateEvents), &error) else {
            throw IdentityError.message("Failed to execure query for username: \(username) with error: \(String(describing: error?.takeRetainedValue().localizedDescription))")
        }

        guard let results = CSIdentityQueryCopyResults(query)?.takeRetainedValue() as? [CSIdentity] else {
            throw IdentityError.message("Failed to copy result of query for username: \(username)")
        }

        return results.first
    }

    static func csIdentityForGroup(_ gid: gid_t) throws -> CSIdentity? {
        guard let authority = CSGetLocalIdentityAuthority()?.takeUnretainedValue() else {
            throw IdentityError.message("Failed to get Local Identity Authority")
        }

        guard let query = CSIdentityQueryCreateForPosixID(kCFAllocatorDefault,
                                                          gid,
                                                          kCSIdentityClassGroup,
                                                          authority)?.takeRetainedValue() else {
                                                        throw IdentityError.message("Failed to create query for group with id: \(gid)")
        }

        var error: Unmanaged<CFError>? = nil
        guard CSIdentityQueryExecute(query, CSIdentityQueryFlags(kCSIdentityQueryGenerateUpdateEvents), &error) else {
            throw IdentityError.message("Failed to execure query for group with id: \(gid) with error: \(String(describing: error?.takeRetainedValue().localizedDescription))")
        }

        guard let results = CSIdentityQueryCopyResults(query)?.takeRetainedValue() as? [CSIdentity] else {
            throw IdentityError.message("Failed to copy result of query for group with id: \(gid)")
        }

        return results.first
    }

    static func isMember(_ username: String, ofGroup group: gid_t) -> Bool {
        guard
            let user = CBIdentity(name: username, authority: .local()),
            let group = CBGroupIdentity(posixGID: group, authority: .local()) else {
                return false
        }
        return user.isMember(ofGroup: group)
    }
}
