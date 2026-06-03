//
//  Color+Extensions.swift
//  zuping001
//

import SwiftUI

// MARK: - Color 扩展
extension Color {
    static var cardBackground: Color {
        #if os(iOS)
        return Color(.secondarySystemGroupedBackground)
        #else
        return Color.white
        #endif
    }
}
