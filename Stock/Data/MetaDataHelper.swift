//
//  MetaDataHelper.swift
//  Stock
//
//  Created by Shunzhe Ma on 2021/05/24.
//

/**
 MetaDataHelper
 
 This file contains functions to extract image and web page title from a given URL.
 */

import Foundation
import LinkPresentation
import CoreServices

class MetaDataHelper {
    
    /// Fetch an icon that represents the dropped item.
    /// - Parameter completionHandler:
    /// 1. The first `Data` is the icon data
    /// 第1のパラメーターはアイコンデータです
    /// 2. The second parameter `String` is the title of the item (if it's website, the title of the page; if it's file, the filename)
    /// 第2のパラメータはアイテムのタイトルです
    /// （ウェブサイトならページのタイトル、ファイルならファイル名となります）
    /// 3. The third parameter is the URL of the item
    /// 第3のパラメーターはアイテムのURLです
    static func fetchItemMetaData(droppedItem: Any, completionHandler: @escaping (Data?, String, URL?) -> Void) {
        if let url = droppedItem as? NSURL {
            if url.isFileURL,
               let filePath = url.path,
               let fileName = url.lastPathComponent {
                // Let the system generate an icon
                let icon = NSWorkspace.shared.icon(forFile: filePath)
                completionHandler(icon.getJpegData(), fileName, url as URL)
            } else {
                /// This is a Internet URL link, fetch the icon using `LinkPresentation` framework
                LPMetadataProvider().startFetchingMetadata(for: url as URL) { metaData, error in
                    /// If failed to fetch the title of the web page, use the URL of the page as the title.
                    let webPageTitle = (metaData?.title) ?? url.description
                    guard let iconProvider = metaData?.iconProvider else {
                        completionHandler(nil, webPageTitle, url as URL); return
                    }
                    iconProvider.loadItem(forTypeIdentifier: kUTTypeImage as String, options: [:]) { data, error in
                        guard let imgData = data as? Data,
                              let imgObj = NSImage(data: imgData) else {
                            completionHandler(nil, webPageTitle, url as URL); return
                        }
                        completionHandler(imgObj.getJpegData(), webPageTitle, url as URL)
                    }
                }
            }
        } else if let text = droppedItem as? NSString {
            completionHandler(nil, text as String, nil)
        } else {
            completionHandler(nil, "Unknown item", nil)
        }
    }
    
}
