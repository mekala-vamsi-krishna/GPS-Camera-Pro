//
//  AppTheme.swift
//  GPS-Camera-Pro
//
//  Created by User on 25/03/26.
//

import Foundation
import SwiftUI

enum AppTheme {
    
    // MARK: - Colors
    enum Colors {
        static let primary = Color("PrimaryColor")
        static let secondary = Color("SecondaryColor")
        static let background = Color("BackgroundColor")
        static let textPrimary = Color("TextPrimary")
        static let textSecondary = Color("TextSecondary")
        static let error =  Color("ErrorColor")
        static let success = Color("SuccessColor")
        static let warning = Color("WarningColor")
    }
   
    // MARK: - Corner Radius
    enum Radius {
        static let small: CGFloat = 6
        static let medium: CGFloat = 12
        static let large: CGFloat = 20
    }
}
