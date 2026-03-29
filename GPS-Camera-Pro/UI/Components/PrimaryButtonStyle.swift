//
//  PrimaryButtonStyle.swift
//  GPS-Camera-Pro
//
//  Created by User on 29/03/26.
//

import Foundation
import  SwiftUI
struct PrimaryButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(AppFont.heading)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(AppTheme.Colors.primary)
            .cornerRadius(AppTheme.Radius.medium)
    }
}

extension View {
    func primaryButtonStyle() -> some View {
        self.modifier(PrimaryButtonStyle())
    }
}
