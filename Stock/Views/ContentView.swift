//
//  ContentView.swift
//  Stock
//
//  Created by Shunzhe Ma on 2021/05/23.
//

import SwiftUI
import LaunchAtLogin

struct ContentView: View {
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \StockItem.addedDate, ascending: false)],
        animation: .default)
    private var items: FetchedResults<StockItem>
    
    @State private var searchText: String = ""
    @State private var allTags: Set<String> = []
    @State private var selectedTag = NSLocalizedString("All", comment: "")
    
    var body: some View {
        Form {
            
            HStack {
                // Search field
                SearchTextFieldView(searchText: $searchText)
                // Button to manually add new item
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(height: 50)
                        .foregroundColor(.init(NSColor.controlBackgroundColor))
                    Image(systemName: "plus")
                        .foregroundColor(.init(NSColor.labelColor))
                        .font(.title2)
                }
                .frame(width: 50)
                .padding(.trailing, 20)
                .padding(.leading, 10)
                .onTapGesture {
                    actionManuallyAddItem()
                }
            }
            
            if items.count > 0 {
                // A dropdown menu to select a specific tag to show
                // 特定のタグを選択して表示するためのドロップダウンメニュー
                HStack {
                    Menu(self.selectedTag) {
                        ForEach(self.allTags.sorted(), id: \.self) { tag in
                            Button(action: {
                                self.selectedTag = tag
                            }) {
                                Text(tag)
                            }
                        }
                    }
                    Button(action: {
                        self.allTags = StorageHelper.shared.getAllTags()
                    }) {
                        Image(systemName: "arrow.counterclockwise.circle.fill")
                    }
                }
                .padding(.horizontal)
                // Scrollview that contains all the stocked items (contains only filtered items if there are search conditions entered)
                // すべてのアイテム
                //（入力された検索条件がある場合は、フィルタリングされた品目のみを含む）
                ScrollView {
                    ForEach(items.filter({ item in
                        // Check tag selection
                        if selectedTag != NSLocalizedString("All", comment: "") {
                            if item.itemTag == nil,
                               selectedTag == NSLocalizedString("Un-Tagged", comment: "") { return true }
                            return item.itemTag == selectedTag
                        }
                        // Check search text
                        /// If `searchText` is empty, do not filter.
                        if searchText.count == 0 { return true }
                        /// Otherwise, check the tag and content
                        let tagMatch = (item.itemTag ?? "").lowercased().contains(searchText.lowercased())
                        let contentMatch = (item.itemName ?? "").lowercased().contains(searchText.lowercased())
                        return tagMatch || contentMatch
                    })) { item in
                        ItemViewCard(itemObject: item)
                    }
                }
                .padding(.top, 10)
            } else {
                // Notices to show
                // when there are no saved items.
                Text("There are no stocked items.").padding()
                Text("Drag a URL link or a file directly to the app icon at the top system bar to save it.").padding()
            }
            // Help buttons
            /// Start with system button
            LaunchAtLogin.Toggle {
                Text("Launch at login")
            }.padding(.horizontal).padding(.top, 10)
            HStack {
                /// Github Link (for open sourced version)
                Button("Support") {
                    NSWorkspace.shared.open(URL(string: "https://github.com/mszpro/ItemStock")!)
                }
                /// License
                Button(action: {
                    let dialog = NSAlert()
                    dialog.messageText = FrameworkLicenseString
                    dialog.addButton(withTitle: "OK")
                    dialog.runModal()
                }) {
                    Text("License")
                }
                Spacer()
                /// Quit app button
                Button(action: {
                    NSApplication.shared.terminate(self)
                }) {
                    Text("Quit app")
                }
            }
            .padding(.horizontal).padding(.bottom, 10).padding(.top, 5)
            
        }
        .padding(.vertical, 10)
        .onAppear {
            self.allTags = StorageHelper.shared.getAllTags()
        }
    }
    
    func actionManuallyAddItem() {
        // Ask the user to enter a text or URL
        let dialog = NSAlert()
        dialog.messageText = NSLocalizedString("Stock an item", comment: "")
        dialog.informativeText = NSLocalizedString("Drag the URL link directly to the app icon on the system bar; or, you can also manually type a URL here.", comment: "")
        let entryBox = NSTextField(frame: .init(x: 0, y: 0, width: 200, height: 100))
        entryBox.stringValue = ""
        entryBox.placeholderString = NSLocalizedString("An URL, a piece of text, a short memo...", comment: "")
        dialog.accessoryView = entryBox
        dialog.addButton(withTitle: NSLocalizedString("Add", comment: ""))
        dialog.addButton(withTitle: NSLocalizedString("Cancel", comment: ""))
        if dialog.runModal() == .alertFirstButtonReturn {
            guard entryBox.stringValue.count > 0 else { return }
            var inputValue: Any = entryBox.stringValue
            if let url = URL(string: entryBox.stringValue) {
                inputValue = url as NSURL
            }
            MetaDataHelper.fetchItemMetaData(droppedItem: inputValue) { iconData, title, fileURL in
                StorageHelper.shared.saveToCoreData(itemURL: fileURL, itemTitle: title, itemIconData: iconData)
            }
        }
    }
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
