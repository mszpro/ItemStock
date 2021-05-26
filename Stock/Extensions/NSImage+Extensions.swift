//
//  NSImage+Extensions.swift
//  Stock
//
//  Created by Shunzhe Ma on 2021/05/24.
//

import Foundation
import Cocoa

extension NSImage {
    func getJpegData() -> Data? {
        guard let cgImg = self.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }
        let bitmap = NSBitmapImageRep(cgImage: cgImg)
        return bitmap.representation(using: .jpeg, properties: [:])
    }
}
