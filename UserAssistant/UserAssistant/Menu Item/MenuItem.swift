//
//  MenuItem.swift
//  UserAssistant
//
//  Created by Erik Berglund on 2018-10-09.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Cocoa

class MenuItem {

    // MARK: -
    // MARK: Static Variables

    static let shared = MenuItem()

    // MARK: -
    // MARK: Variables

    var item: NSStatusItem?

    let menuItemComputerInfo = MenuItemComputerInfo()
    let menuItemElevatePrivileges = MenuItemElevatePrivileges()

    // MARK: -
    // MARK: Functions

    func showMenuItem() {

        if self.item == nil {
            self.item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        }

        self.item?.title = "Schibsted"
        self.item?.menu = self.menu()
    }

    func menu() -> NSMenu {

        let menu = NSMenu()

        // MenuItem: Computer
        menu.addItem(self.menuItemComputerInfo)
        menu.addItem(NSMenuItem.separator())

        // MenuItem: Elevate Privileges
        menu.addItem(self.menuItemElevatePrivileges)
        
        return menu
    }
}
