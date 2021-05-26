//
//  StorageHelper.swift
//  MenuBarTODO
//
//  Created by Shunzhe Ma on R 3/01/21.
//

import Foundation
import CoreData

class StorageHelper {
    
    static let shared = StorageHelper()
    
    let storageContext: NSManagedObjectContext
    
    private init() {
        let container = NSPersistentCloudKitContainer(name: "Stock")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                print(error.localizedDescription)
            }
        })
        let context = container.viewContext
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        self.storageContext = context
    }
    
    /// Save all the given input to a new stock item entry.
    /// 全入力内容を新規保存アイテムエントリーに保存します。
    /// - Parameters:
    ///   - itemURL: The URL of the item. It can be a website URL or a path to a local file. **Note that this app does not backup the content of the file. It just saves a path.** アイテムのURL。ウェブサイトのURLかローカルファイルのパスになります。 **このアプリはファイルの内容はバックアップしないことにご注意ください。保存されるのはパスのみです。**
    ///   - itemTitle: The text representation of the item. アイテムのテキスト
    ///   - itemIconData: The icon of the item (if there's any icon fetched). アイテムのアイコン（フェッチされたアイコンがある場合）。
    func saveToCoreData(itemURL: URL?, itemTitle: String, itemIconData: Data?) {
        let newItem = StockItem(context: storageContext)
        newItem.itemID = UUID().uuidString
        newItem.addedDate = Date()
        newItem.itemURL = itemURL
        newItem.itemName = itemTitle
        newItem.itemIconData = itemIconData
        newItem.itemUnread = true
        do {
            try storageContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getUnreadItemCounting() -> Int {
        let savedPlaceFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "StockItem")
        do {
            let result = try storageContext.fetch(savedPlaceFetch)
            return result.filter { item in
                guard let savedItem = item as? StockItem else { return false }
                return savedItem.itemUnread
            }.count
        } catch {
            return 0
        }
    }
    
    func getAllTags() -> Set<String> {
        let savedPlaceFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "StockItem")
        var allTags: Set<String> = [NSLocalizedString("All", comment: "")]
        do {
            guard let result = try storageContext.fetch(savedPlaceFetch) as? [StockItem] else {
                return []
            }
            for item in result {
                allTags.insert(item.itemTag ?? NSLocalizedString("Un-Tagged", comment: ""))
            }
            return allTags
        } catch {
            return []
        }
    }
    
}
