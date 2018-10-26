//
//  Helper.swift
//  com.github.erikberglund.UserAssistantHelper
//
//  Created by Erik Berglund.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Foundation
import Collaboration

class Helper: NSObject, NSXPCListenerDelegate, HelperProtocol {

    // MARK: -
    // MARK: Private Constant Variables

    private let listener: NSXPCListener

    // MARK: -
    // MARK: Private Variables

    private var connections = [NSXPCConnection]()
    private var shouldQuit = false
    private var shouldQuitCheckInterval = 1.0

    // MARK: -
    // MARK: Initialization

    override init() {
        self.listener = NSXPCListener(machServiceName: HelperConstants.machServiceName)
        super.init()
        self.listener.delegate = self
    }

    public func run() {
        self.listener.resume()

        // Keep the helper tool running until the variable shouldQuit is set to true.
        // The variable should be changed in the "listener(_ listener:shoudlAcceptNewConnection:)" function.

        while !self.shouldQuit {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: self.shouldQuitCheckInterval))
        }
    }

    // MARK: -
    // MARK: NSXPCListenerDelegate Methods

    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection connection: NSXPCConnection) -> Bool {

        // Verify that the calling application is signed using the same code signing certificate as the helper
        guard self.isValid(connection: connection) else {
            return false
        }

        // Set the protocol that the calling application conforms to.
        connection.remoteObjectInterface = NSXPCInterface(with: AppProtocol.self)

        // Set the protocol that the helper conforms to.
        connection.exportedInterface = NSXPCInterface(with: HelperProtocol.self)
        connection.exportedObject = self

        // Set the invalidation handler to remove this connection when it's work is completed.
        connection.invalidationHandler = {
            if let connectionIndex = self.connections.firstIndex(of: connection) {
                self.connections.remove(at: connectionIndex)
            }

            if self.connections.isEmpty {
                self.shouldQuit = true
            }
        }

        self.connections.append(connection)
        connection.resume()

        return true
    }

    // MARK: -
    // MARK: HelperProtocol Methods

    func getVersion(completion: (String) -> Void) {
        completion(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0")
    }

    func groupAdminAdd(_ username: String, authData: NSData?, completion: @escaping (NSNumber) -> Void) {

        // Check the passed authorization, if the user need to authenticate to use this command the user might be prompted depending on the settings and/or cached authentication.

        guard self.verifyAuthorization(authData, forCommand: #selector(HelperProtocol.groupAdminAdd(_:authData:completion:))) else {
            completion(kAuthorizationFailedExitCode)
            return
        }

        do {
            let userIdentity = try Identity.csIdentityForUser(username)
            let groupIdentity = try Identity.csIdentityForGroup(kGIDAdmin)

            if let remoteObject = self.connection()?.remoteObjectProxy as? AppProtocol {
                remoteObject.log(stdErr: "User Is: \(String(describing: userIdentity)), groupIs: \(String(describing: groupIdentity))")
            }
        } catch {
            if let remoteObject = self.connection()?.remoteObjectProxy as? AppProtocol {
                remoteObject.log(stdErr: "error: \(error)")
            }
        }
    }

    func groupAdminRemove(_ username: String, completion: @escaping (NSError) -> Void) {

        do {
            let userIdentity = try Identity.csIdentityForUser(username)
            let groupIdentity = try Identity.csIdentityForGroup(kGIDAdmin)

            if let remoteObject = self.connection()?.remoteObjectProxy as? AppProtocol {
                remoteObject.log(stdErr: "User Is: \(String(describing: userIdentity)), groupIs: \(String(describing: groupIdentity))")
            }
        } catch {
            if let remoteObject = self.connection()?.remoteObjectProxy as? AppProtocol {
                remoteObject.log(stdErr: "error: \(error)")
            }
        }
    }

    func firmwarePasswordCheck(completion: @escaping (_ enabled: String?, _ error: String?) -> Void) {
        runTask(command: "/usr/sbin/firmwarepasswd", arguments: ["-check"]) { (stdOut, stdErr, exitCode) in
            guard exitCode == 0, let status = stdOut else {
                completion(nil, stdErr);
                return
            }

            var isEnabled: String?

            for line in status.components(separatedBy: "\n") {
                if line.hasPrefix("Password Enabled"), let enabledString = line.components(separatedBy: ":").last {
                    isEnabled = enabledString
                    break
                }
            }

            completion(isEnabled, nil)
        }
    }

    // MARK: -
    // MARK: Private Helper Methods

    private func isValid(connection: NSXPCConnection) -> Bool {
        do {
            return try CodesignCheck.codeSigningMatches(pid: connection.processIdentifier)
        } catch {
            NSLog("Code signing check failed with error: \(error)")
            return false
        }
    }

    private func verifyAuthorization(_ authData: NSData?, forCommand command: Selector) -> Bool {
        do {
            try HelperAuthorization.verifyAuthorization(authData, forCommand: command)
        } catch {
            if let remoteObject = self.connection()?.remoteObjectProxy as? AppProtocol {
                remoteObject.log(stdErr: "Authentication Error: \(error)")
            }
            return false
        }
        return true
    }

    private func connection() -> NSXPCConnection? {
        return self.connections.last
    }

    private func runHelperTask(command: String, arguments: Array<String>, completion:@escaping ((NSNumber) -> Void)) -> Void {
        let task = Process()
        let stdOut = Pipe()

        let stdOutHandler =  { (file: FileHandle!) -> Void in
            let data = file.availableData
            guard let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return }
            if let remoteObject = self.connection()?.remoteObjectProxy as? AppProtocol {
                remoteObject.log(stdOut: output as String)
            }
        }
        stdOut.fileHandleForReading.readabilityHandler = stdOutHandler

        let stdErr:Pipe = Pipe()
        let stdErrHandler =  { (file: FileHandle!) -> Void in
            let data = file.availableData
            guard let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return }
            if let remoteObject = self.connection()?.remoteObjectProxy as? AppProtocol {
                remoteObject.log(stdErr: output as String)
            }
        }
        stdErr.fileHandleForReading.readabilityHandler = stdErrHandler

        task.launchPath = command
        task.arguments = arguments
        task.standardOutput = stdOut
        task.standardError = stdErr

        task.terminationHandler = { task in
            completion(NSNumber(value: task.terminationStatus))
        }

        task.launch()
    }
}
