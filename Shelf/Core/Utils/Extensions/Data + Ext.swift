//
//  Data + Ext.swift
//  Shelf
//
//  Created by Sk Jasimuddin on 30/04/25.
//

import Foundation
extension Date {
    func iso8601String() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: self)
    }
}
