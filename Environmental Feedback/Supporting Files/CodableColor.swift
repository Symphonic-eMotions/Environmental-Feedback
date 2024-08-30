//
//  CodableColor.swift
//  Environmental Feedback
//
//  Created by Frans-Jan Wind on 30/08/2024.
//

import SwiftUI

struct CodableColor: Codable {
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double
    
    // Initialiseer vanuit een SwiftUI Color
    init(color: Color) {
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        self.red = Double(red)
        self.green = Double(green)
        self.blue = Double(blue)
        self.alpha = Double(alpha)
    }
    
    // Converteer terug naar een SwiftUI Color
    func toColor() -> Color {
        return Color(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}
