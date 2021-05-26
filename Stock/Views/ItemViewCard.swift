//
//  ItemViewCard.swift
//  Stock
//
//  Created by Shunzhe Ma on 2021/05/24.
//

import SwiftUI

/**
 The individual cell of the table view that shows one saved item.
 */
struct ItemViewCard: View {
    
    @ObservedObject var itemObject: StockItem
    
    var body: some View {
        Section {
            
            VStack(alignment: .leading) {
                
                HStack {
                    
                    if itemObject.itemUnread {
                        Image(systemName: "circlebadge.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 10)
                            .foregroundColor(.blue)
                    }
                    
                    // Icon on the left
                    if let previewImageData = itemObject.itemIconData,
                       let imgObject = NSImage(data: previewImageData) {
                        Image(nsImage: imgObject)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35)
                            .cornerRadius(5)
                            .shadow(radius: 5)
                            .padding(5)
                    } else {
                        Image(systemName: "doc.text")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25)
                            .padding(5)
                    }
                    
                    // Title and the URL
                    VStack(alignment: .leading) {
                        Text(itemObject.itemName?.getFirstCharacters(count: 200) ?? "Unknown item")
                            .font(.headline)
                        if let url = itemObject.itemURL {
                            Text(url.absoluteString.getFirstCharacters(count: 100))
                        }
                        if let itemTag = itemObject.itemTag {
                            TagView(tagContent: itemTag)
                        }
                        if let dueDate = itemObject.dueDate {
                            HStack {
                                Image(systemName: "calendar.badge.clock")
                                    .foregroundColor((dueDate < Date()) ? .red : .blue)
                                Text(DateFormatter.localizedString(from: dueDate, dateStyle: .medium, timeStyle: .short))
                            }
                        }
                    }
                    .padding(.horizontal, 5)
                    
                    Spacer()
                    
                    // Action menu
                    Menu {
                        // Options only for local files
                        if let itemURL = itemObject.itemURL,
                           itemURL.isFileURL {
                            // Get iCloud link
                            if FileManager.default.isUbiquitousItem(at: itemURL) {
                                Button(action: {
                                    actionGetiCloudLink()
                                }) {
                                    Text("Copy iCloud link")
                                }
                            }
                        }
                        // Share web page URL
                        if let itemURL = itemObject.itemURL,
                           !itemURL.isFileURL {
                            Button(action: {
                                actionOpenShareMenu()
                            }) {
                                Text("Share URL")
                            }
                        }
                        // Mark as unread
                        Button(action: {
                            actionMarkAsRead()
                        }) {
                            Text(itemObject.itemUnread ? NSLocalizedString("Mark as read", comment: "") : NSLocalizedString("Mark as unread", comment: ""))
                        }
                        // Edit details
                        Button(action: {
                            actionPresentEditDialog()
                        }) {
                            Text("Edit")
                        }
                        // Add due date button
                        Button {
                            actionEditDueDate()
                        } label: {
                            Text("Add deadline")
                        }
                        // Delete item button
                        Button(action: {
                            actionDelete()
                        }) {
                            Text("Delete")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle.fill")
                    }.frame(width: 50)
                    
                }
                
            }
            
            .padding(.horizontal, 10)
            .padding(.bottom, 10)
            
            .onTapGesture {
                actionOpen()
            }
            
            .onDrag {
                if let url = self.itemObject.itemURL {
                    if url.isFileURL {
                        return NSItemProvider(object: url.path as NSString)
                    }
                    return NSItemProvider(object: url as NSURL)
                }
                return NSItemProvider(object: (itemObject.itemName ?? "") as NSString)
            }
            
        }
    }
    
    func actionOpen() {
        itemObject.itemUnread = false
        try? StorageHelper.shared.storageContext.save()
        if let itemURL = itemObject.itemURL {
            if itemURL.isFileURL {
                // Open the finder location
                NSWorkspace.shared.activateFileViewerSelecting([itemURL])
            } else {
                // Open web page
                NSWorkspace.shared.open(itemURL)
            }
        } else {
            // Show an alert with text
            let alert = NSAlert()
            alert.messageText = self.itemObject.itemName ?? ""
            alert.addButton(withTitle: NSLocalizedString("Copy to clipboard", comment: ""))
            alert.addButton(withTitle: "OK")
            if alert.runModal() == .alertFirstButtonReturn {
                let pasteboard = NSPasteboard.general
                pasteboard.declareTypes([.string], owner: nil)
                pasteboard.setString(self.itemObject.itemName ?? "", forType: .string)
            }
        }
    }
    
    func actionGetiCloudLink() {
        if let itemURL = itemObject.itemURL,
           let shareURL = try? FileManager.default.url(forPublishingUbiquitousItemAt: itemURL, expiration: nil) {
            let pasteboard = NSPasteboard.general
            pasteboard.declareTypes([.string], owner: nil)
            pasteboard.setString(shareURL.absoluteString, forType: .string)
            let alert = NSAlert()
            alert.messageText = NSLocalizedString("Share with iCloud", comment: "")
            alert.informativeText = NSLocalizedString("The iCloud sharing link has been copied to your pasteboard.", comment: "")
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
    
    func actionOpenShareMenu() {
        guard let itemURL = itemObject.itemURL else { return }
        let picker = NSSharingServicePicker(items: [itemURL])
        if let view = (NSApplication.shared.delegate as? AppDelegate)?.popover.contentViewController?.view {
            picker.show(relativeTo: .zero, of: view, preferredEdge: .minX)
        }
    }
    
    func actionMarkAsRead() {
        itemObject.itemUnread.toggle()
        try? StorageHelper.shared.storageContext.save()
    }
    
    func actionPresentEditDialog() {
        let dialog = NSAlert()
        dialog.messageText = NSLocalizedString("Edit item details", comment: "")
        let itemTitleBox = NSTextField(frame: .init(x: 0, y: 35, width: 200, height: 30))
        itemTitleBox.stringValue = self.itemObject.itemName ?? ""
        itemTitleBox.layer?.cornerRadius = 15
        itemTitleBox.layer?.masksToBounds = true
        let tagEntryBox = NSTextField(frame: .init(x: 0, y: 0, width: 200, height: 30))
        tagEntryBox.stringValue = self.itemObject.itemTag ?? ""
        tagEntryBox.placeholderString = "Tag"
        tagEntryBox.layer?.masksToBounds = true
        tagEntryBox.layer?.cornerRadius = 15
        let textBoxStack = NSStackView(frame: .init(x: 0, y: 0, width: 200, height: 65))
        textBoxStack.addSubview(itemTitleBox)
        textBoxStack.addSubview(tagEntryBox)
        dialog.accessoryView = textBoxStack
        if let previewImageData = itemObject.itemIconData {
            dialog.icon = NSImage(data: previewImageData)
        }
        dialog.addButton(withTitle: "OK")
        dialog.addButton(withTitle: NSLocalizedString("Cancel", comment: ""))
        if dialog.runModal() == .alertFirstButtonReturn {
            // Save the tag
            guard itemTitleBox.stringValue.count > 0 else {
                return
            }
            // Prefix a # sign if it's not there
            var tagValue = tagEntryBox.stringValue
            if !tagValue.starts(with: "#") { tagValue.insert("#", at: tagValue.startIndex) }
            self.itemObject.itemTag = tagValue
            if tagEntryBox.stringValue.count == 0 {
                // Remove the tag value if it's empty
                self.itemObject.itemTag = nil
            }
            self.itemObject.itemName = itemTitleBox.stringValue
            try? StorageHelper.shared.storageContext.save()
        }
    }
    
    func actionEditDueDate() {
        let dialog = NSAlert()
        dialog.messageText = NSLocalizedString("Add a due date for this item.", comment: "")
        let datePicker = NSDatePicker(frame: .init(x: 0, y: 0, width: 200, height: 20))
        if let date = itemObject.dueDate {
            datePicker.dateValue = date
        } else {
            datePicker.dateValue = Date()
        }
        dialog.accessoryView = datePicker
        dialog.addButton(withTitle: NSLocalizedString("Set deadline", comment: ""))
        dialog.addButton(withTitle: NSLocalizedString("Cancel", comment: ""))
        if dialog.runModal() == .alertFirstButtonReturn {
            itemObject.dueDate = datePicker.dateValue
            try? StorageHelper.shared.storageContext.save()
        }
    }
    
    func actionDelete() {
        StorageHelper.shared.storageContext.delete(itemObject)
        try? StorageHelper.shared.storageContext.save()
    }
    
}
