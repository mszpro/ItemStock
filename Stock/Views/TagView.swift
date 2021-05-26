//
//  TagView.swift
//  Stock
//
//  Created by Shunzhe Ma on 2021/05/24.
//

import SwiftUI

/**
 Shows a rounded rectangle with blue background and text.
 */
public struct TagView: View {
    
    var tagContent: String
    
    var textFont: Font
    var textPadding: CGFloat
    
    var onTagSelected: (String) -> Void
    
    public init(tagContent: String, textFont: Font = .headline, textPadding: CGFloat = 5, onTagSelected: @escaping (String) -> Void = { _ in } ) {
        self.tagContent = tagContent
        self.textFont = textFont
        self.textPadding = textPadding
        self.onTagSelected = onTagSelected
    }
    public var body: some View {
        Text(tagContent)
            .font(textFont)
            .foregroundColor(.white)
            .padding(textPadding)
            .background(RoundedRectangle(cornerRadius: 6).foregroundColor(.blue))
            .onTapGesture(perform: {
                self.onTagSelected(tagContent)
            })
    }
}
