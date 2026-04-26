//
//  Theme.swift
//  NewsFlow
//
//  Created by Anatolii Semenchuk on 26.04.2026.
//

import UIKit

enum Theme {
    
    enum Color {
        static let background = UIColor(hex: "#FDF6F0")  // warm cream
        static let surface = UIColor(hex: "#F5EAE0")  // cards
        static let inputBackground = UIColor(hex: "#F2E0D0")  // pills, inputs
        
        static let accent = UIColor(hex: "#C05A2A")  // terracotta
        static let accentDark = UIColor(hex: "#8A3A15")  // pressed state
        
        static let textPrimary = UIColor(hex: "#3D2010")  // headings
        static let textSecondary = UIColor(hex: "#8A4020")  // subheadings
        static let textTertiary = UIColor(hex: "#A06040")  // metadata
        
        static let separator = UIColor(hex: "#C05A2A").withAlphaComponent(0.15)
        static let barBackground = UIColor(hex: "#FDF6F0")
        static let heroOverlay = UIColor(hex: "#140802")
    }
    
    enum Font {
        static func regular(_ size: CGFloat)  -> UIFont { .systemFont(ofSize: size, weight: .regular) }
        static func medium(_ size: CGFloat)   -> UIFont { .systemFont(ofSize: size, weight: .medium) }
        static func semibold(_ size: CGFloat) -> UIFont { .systemFont(ofSize: size, weight: .semibold) }
        
        static let heroHeadline = semibold(20)
        static let cardTitle = medium(15)
        static let rowTitle = medium(14)
        static let categoryLabel = medium(13)
        static let metadata = regular(12)
        static let tag = medium(11)
        static let detailTitle = semibold(22)
        static let detailBody = regular(16)
    }
    
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
    }
    
    enum Radius {
        static let sm:   CGFloat = 6
        static let md:   CGFloat = 10
        static let lg:   CGFloat = 14
        static let pill: CGFloat = 100
    }
}

extension UIColor {
    convenience init(hex: String) {
        var hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hex = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
        
        var rgb: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgb)
        
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255
        let g = CGFloat((rgb & 0x00FF00) >> 8)  / 255
        let b = CGFloat(rgb & 0x0000FF)          / 255
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}
