//
//  MenuItemElevatePrivileges.swift
//  UserAssistant
//
//  Created by Erik Berglund on 2018-10-11.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Cocoa
import Collaboration

class MenuItemElevatePrivileges: NSMenuItem {

    // MARK: -
    // MARK: Variables

    var timer: Timer?
    var int = 0
    var endDate: Date?

    // MARK: -
    // MARK: Initialization

    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init() {
        super.init(title: "Elevate Privileges", action: #selector(self.clicked), keyEquivalent: "")
        self.target = self
    }

    @objc func updateTimer() {

        // Pretend Date
        let competitionDate = NSDateComponents()
        competitionDate.hour = 16
        competitionDate.minute = 00
        competitionDate.second = 00
        let endDate = Calendar.current.date(from: competitionDate as DateComponents)

        guard let futureDate = endDate else {
            return
        }

        let dateDifferenceComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: Date(), to: futureDate)
        let dateDifference = Calendar.current.date(from: dateDifferenceComponents)

        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "HH:mm:ss"

        self.title = "Remove Privileges (\(dateFormatterGet.string(from: dateDifference ?? Date())))"
    }

    @objc func clicked() {

        do {
            if Identity.isMember(NSUserName(), ofGroup: kGIDAdmin) {
                Swift.print("IS MEMBER!")
            }

            guard
                let helper = HelperConnection.shared.helper(nil),
                let authData = try HelperAuthorization.emptyAuthorizationExternalFormData() else {
                return
            }

            helper.groupAdminAdd(NSUserName(), authData: authData) { (error) in
                Swift.print("error: \(error)")
            }

            let timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
            self.timer = timer
            RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
        } catch {
            Swift.print("Error: \(error)")
        }
    }
/*
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
 */
}
