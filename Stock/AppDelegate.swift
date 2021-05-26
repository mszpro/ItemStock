//
//  AppDelegate.swift
//  Stock
//
//  Created by Shunzhe Ma on 2021/05/23.
//

import Cocoa
import SwiftUI
import UserNotifications

@main
class AppDelegate: NSObject, NSApplicationDelegate, NSPopoverDelegate {
    
    var popover: NSPopover!
    var statusBarItem: NSStatusItem!
    
    let persistenceController = StorageHelper.shared

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // The `ContentView` will show when the user clicks on the menu bar icon
        let contentView = ContentView().environment(\.managedObjectContext, persistenceController.storageContext)
        // Set up the popover
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 350, height: 500)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: contentView)
        popover.delegate = self
        self.popover = popover
        // Set up the appearance (icon image) and action
        self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        guard let button = self.statusBarItem.button else { return }
        button.image = NSImage(systemSymbolName: "tray.full.fill", accessibilityDescription: nil)
        button.imagePosition = .imageLeft
        button.title = "\(persistenceController.getUnreadItemCounting())"
        button.action = #selector(showHidePopover(_:))
        button.window?.registerForDraggedTypes([.URL, .string])
        button.window?.delegate = self
    }
    
    func popoverWillClose(_ notification: Notification) {
        // Reload the unread counter
        self.statusBarItem.button?.title = "\(self.persistenceController.getUnreadItemCounting())"
    }
    
    /**
     This function runs when the user clicks on the menu bar icon.
     この関数は、ドロップされたアイテムを表すアイコンをフェッチします。
     It will show or hide the `ContentView`
     */
    @objc func showHidePopover(_ sender: AnyObject?) {
        guard let button = self.statusBarItem.button else { return }
        if self.popover.isShown {
            self.popover.performClose(sender)
        } else {
            NSApplication.shared.activate(ignoringOtherApps: true)
            self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            self.popover.contentViewController?.view.window?.becomeKey()
        }
        button.title = "\(persistenceController.getUnreadItemCounting())"
    }

}

extension AppDelegate: NSWindowDelegate, NSDraggingDestination {
    
    func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        print(sender)
        return .link
    }
    
    func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        return sender.draggingSourceOperationMask
    }
    
    func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        /// Note: Only accept one dropped item
        if let firstObject = sender.draggingPasteboard.readObjects(forClasses: [NSURL.self, NSString.self])?.first {
            MetaDataHelper.fetchItemMetaData(droppedItem: firstObject) { iconData, itemTitle, itemURL in
                // Save the item to Core Data
                self.persistenceController.saveToCoreData(itemURL: itemURL, itemTitle: itemTitle, itemIconData: iconData)
                // Update unread counter
                DispatchQueue.main.async {
                    self.statusBarItem.button?.title = "\(self.persistenceController.getUnreadItemCounting())"
                }
                // Remind first-time user that only a file path is saved, not the actual file
                if !UserDefaults.standard.bool(forKey: "file-path-reminder_shown") {
                    UserDefaults.standard.set(true, forKey: "file-path-reminder_shown")
                    DispatchQueue.main.async {
                        let alert = NSAlert()
                        alert.informativeText = NSLocalizedString("Only file references are saved. If you delete or move the file, this app will not be able to open the file.", comment: "")
                        alert.addButton(withTitle: "OK")
                        alert.runModal()
                    }
                }
            }
            return true
        }
        return false
    }
    
}
