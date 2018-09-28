//
//  Task.swift
//  UserAssistant
//
//  Created by Erik Berglund on 2018-08-29.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Foundation

func runTask(command: String, arguments: [String], completionHandler: @escaping (_ stdOut: String?, _ stdErr: String?, _ exitCode: Int32) -> Void) {

    let task:Process = Process()

    var stdOut: String?
    let stdOutPipe = Pipe()

    var stdErr: String?
    let stdErrPipe = Pipe()

    task.standardOutput = stdOutPipe
    task.standardError = stdErrPipe
    task.launchPath = command
    task.arguments = arguments
    task.launch()

    let outdata = stdOutPipe.fileHandleForReading.readDataToEndOfFile()
    if let stdOutString = String(data: outdata, encoding: .utf8) {
        stdOut = stdOutString
    }

    let errdata = stdErrPipe.fileHandleForReading.readDataToEndOfFile()
    if let stdErrString = String(data: errdata, encoding: .utf8) {
        stdErr = stdErrString
    }

    task.waitUntilExit()

    completionHandler(stdOut, stdErr, task.terminationStatus)
}

func runScript(_ script: String, completionHandler: @escaping (_ stdOut: String?, _ stdErr: String?, _ exitCode: Int32) -> Void) {

    guard let scriptHeader = script.components(separatedBy: .newlines).filter({ !$0.isEmpty }).first?.replacingOccurrences(of: "#!", with: "") else {
        completionHandler(nil, nil, -1)
        return
    }

    var command: String
    var arguments: [String]
    if scriptHeader.contains("bash") {
        command = "/bin/bash"
        arguments = ["-c", script]
    } else if scriptHeader.contains("python") {
        command = "/usr/bin/python"
        arguments = [script]
    } else {
        completionHandler(nil, nil, -1)
        return
    }

    runTask(command: command, arguments: arguments, completionHandler: completionHandler)
}
