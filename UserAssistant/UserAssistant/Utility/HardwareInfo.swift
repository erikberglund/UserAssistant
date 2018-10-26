//
//  HardwareInfo.swift
//  UserAssistant
//
//  Created by Erik Berglund on 2018-10-09.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Foundation

class HardwareInfo {

    // MARK: -
    // MARK: Static Variables

    static let shared = HardwareInfo()

    // MARK: -
    // MARK: Lazy Variables

    lazy var machineSerialNumber: String? = {
        let platformExpert = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice") )
        guard 0 < platformExpert else { return nil }
        guard let platformExpertSN = IORegistryEntryCreateCFProperty(platformExpert,
                                                                     kIOPlatformSerialNumberKey as CFString,
                                                                     kCFAllocatorDefault, 0).takeUnretainedValue() as? String else { return nil }
        IOObjectRelease(platformExpert)
        return platformExpertSN.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }()

    lazy var machineConfigurationCode: String? = {
        guard let sn = machineSerialNumber, (sn.count == 11 || sn.count == 12) else { return nil }
        return String(sn.suffix(4))
    }()

    // MARK: -
    // MARK: Functions

    func getMachineModelName(completion: @escaping (_ name: String?) -> Void) {
        guard
            let configCode = machineConfigurationCode,
            let language = Locale.preferredLanguages.first,
            let region = Locale.current.regionCode else {
                completion(nil)
                return
        }

        let computerString = configCode + "-" + language + "_" + region

        if
            let cpuNames = UserDefaults.standard.dictionary(forKey: "CPU Names"),
            let modelName = cpuNames[computerString] as? String {
            completion(modelName)
            return
        } else if
            let cpuNames = UserDefaults(suiteName: "com.apple.SystemProfiler")?.dictionary(forKey: "CPU Names"),
            let modelName = cpuNames[computerString] as? String {
            UserDefaults.standard.setValue([computerString: modelName], forKey: "CPU Names")
            completion(modelName)
            return
        } else {
            // FIXME: Call Apples server and get the model name
        }
    }

}
