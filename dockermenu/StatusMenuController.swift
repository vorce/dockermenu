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
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    let dockerApi = Docker()
    
    override func awakeFromNib() {
        let icon = NSImage(named: "IconSet")
        icon?.template = true
        
        statusItem.image = icon
        statusItem.menu = statusMenu
        
        NSTimer.scheduledTimerWithTimeInterval(30.0, target: self, selector: Selector("dockerPs"), userInfo: nil, repeats: true)

        debugPrint(dockerApi.dockerImages())
        addMenuItems(dockerApi.dockerImages())
    }
    
    @IBAction func quitClicked(sender: NSMenuItem) {
        NSApplication.sharedApplication().terminate(self)
    }
    
    func dockerPs() {
        let images = dockerApi.dockerImages()
        debugPrint("Updating list of running docker images")
        removeAllImageItems()
        addMenuItems(images)
    }
    
    @IBAction func stopAllClicked(sender: NSMenuItem) {
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            self.dockerApi.stopAll(self.dockerApi.dockerImages())
            dispatch_async(dispatch_get_main_queue()) {
                self.removeAllImageItems()
            }
        }
    }
    
    func removeAllImageItems() {
        let menuItems = statusItem.menu!.itemArray
        for item in menuItems {
            if(item.action.description.containsString("stopImage")) {
                debugPrint("Removing item from menu: " + item.description)
                statusItem.menu?.removeItem(item)
            }
        }
    }
    
    @IBAction func stopImage(sender: NSMenuItem) {
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            let containerId = sender.representedObject as! String
            self.dockerApi.stopContainer(containerId)
            dispatch_async(dispatch_get_main_queue()) {
                if(self.statusItem.menu!.itemArray.contains(sender)) {
                    self.statusItem.menu?.removeItem(sender)
                }
            }
        }
    }
    
    func addMenuItems(images: [DockerImage]) {
        images.forEach  { (image: DockerImage) -> () in
            let newItem : NSMenuItem = NSMenuItem(title: image.name, action: Selector("stopImage:"), keyEquivalent: "")
            newItem.representedObject = image.containerId
            newItem.target = self
            statusItem.menu!.addItem(newItem)
        }
    }
}
