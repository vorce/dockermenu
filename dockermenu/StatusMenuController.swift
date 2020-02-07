//
//  StatusMenuController.swift
//  dockermenu
//
//  Created by Joel Carlbark on 2016-06-17.
//  Copyright © 2016 Joel Carlbark. All rights reserved.
//

import Cocoa

class StatusMenuController: NSObject {
    @IBOutlet weak var statusMenu: NSMenu!
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let dockerApi = Docker()
    
    override func awakeFromNib() {
        let icon = NSImage(named: "IconSet")
        icon?.isTemplate = true
        
        statusItem.image = icon
        statusItem.menu = statusMenu
        
        Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(StatusMenuController.dockerPs), userInfo: nil, repeats: true)

        debugPrint("Running docker images: ", dockerApi.dockerImages())
        addMenuItems(dockerApi.dockerImages())
    }
    
    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
    
    @objc func dockerPs() {
        let images = dockerApi.dockerImages()
        removeAllImageItems()
        addMenuItems(images)
    }
    
    @IBAction func stopAllClicked(_ sender: NSMenuItem) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.dockerApi.stopAll(self.dockerApi.dockerImages())
            DispatchQueue.main.async {
                self.removeAllImageItems()
            }
        }
    }
    
    func removeAllImageItems() {
        let menuItems = statusItem.menu!.items
        debugPrint("menu items: ", menuItems)
        for item in menuItems {
            if((item.action != nil) && (item.action?.description.contains("stopImage"))!) {
                debugPrint("Removing item from menu: " + item.description)
                statusItem.menu?.removeItem(item)
            }
        }
    }
    
    @IBAction func stopImage(_ sender: NSMenuItem) {
        DispatchQueue.global(qos: .userInitiated).async {
            let containerId = sender.representedObject as! String
            self.dockerApi.stopContainer(containerId)
            DispatchQueue.main.async {
                if(self.statusItem.menu!.items.contains(sender)) {
                    self.statusItem.menu?.removeItem(sender)
                }
            }
        }
    }
    
    func addMenuItems(_ images: [DockerImage]) {
        images.forEach  { (image: DockerImage) -> () in
            let newItem : NSMenuItem = NSMenuItem(title: image.name, action: #selector(StatusMenuController.stopImage(_:)), keyEquivalent: "")
            debugPrint("Adding menu item", newItem)
            newItem.representedObject = image.containerId
            newItem.target = self
            statusItem.menu!.addItem(newItem)
        }
    }
}
