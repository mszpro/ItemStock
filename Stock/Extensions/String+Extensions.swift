//
//  String+Extensions.swift
//  Stock
//
//  Created by Shunzhe Ma on 2021/05/24.
//

import Foundation

extension String {
    func getFirstCharacters(count: Int) -> String {
        /// If the string contains less character than the `count` number, directly return the string.
        if self.count <= count {
            return self
        } else {
            return self.prefix(count) + "..."
        }
    }
}
