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
    
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    let dockerApi = Docker()
    
    override func awakeFromNib() {
        let icon = NSImage(named: "IconSet")
        icon?.isTemplate = true
        
        statusItem.image = icon
        statusItem.menu = statusMenu
        
        Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(StatusMenuController.dockerPs), userInfo: nil, repeats: true)

        debugPrint(dockerApi.dockerImages())
        addMenuItems(dockerApi.dockerImages())
    }
    
    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }
    
    func dockerPs() {
        let images = dockerApi.dockerImages()
        debugPrint("Updating list of running docker images")
        removeAllImageItems()
        addMenuItems(images)
    }
    
    @IBAction func stopAllClicked(_ sender: NSMenuItem) {
        let priority = DispatchQueue.GlobalQueuePriority.default
        DispatchQueue.global(priority: priority).async {
            self.dockerApi.stopAll(self.dockerApi.dockerImages())
            DispatchQueue.main.async {
                self.removeAllImageItems()
            }
        }
    }
    
    func removeAllImageItems() {
        let menuItems = statusItem.menu!.items
        for item in menuItems {
            if(item.action?.description.contains("stopImage"))! {
                debugPrint("Removing item from menu: " + item.description)
                statusItem.menu?.removeItem(item)
            }
        }
    }
    
    @IBAction func stopImage(_ sender: NSMenuItem) {
        let priority = DispatchQueue.GlobalQueuePriority.default
        DispatchQueue.global(priority: priority).async {
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
            newItem.representedObject = image.containerId
            newItem.target = self
            statusItem.menu!.addItem(newItem)
        }
    }
}
