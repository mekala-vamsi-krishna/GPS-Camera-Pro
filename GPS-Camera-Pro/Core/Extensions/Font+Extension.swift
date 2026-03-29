//
//  Font+Extension.swift
//  GPS-Camera-Pro
//
//  Created by User on 29/03/26.
//
import SwiftUI

extension Font {
    
    enum CustomFontWeight {
        case regular
        case medium
        case semibold
        case bold
    }
    
    static func customFont(
        _ weight: CustomFontWeight = .regular,
        size: CGFloat,
        relativeTo style: Font.TextStyle = .body
    ) -> Font {
        
        let fontName: String
        
        switch weight {
        case .regular: fontName = "Figtree-Regular"
        case .medium: fontName = "Figtree-Medium"
        case .semibold: fontName = "Figtree-Semibold"
        case .bold: fontName = "Figtree-Bold"
        }
        
        return Font.custom(fontName, size: size, relativeTo: style)
    }
}
