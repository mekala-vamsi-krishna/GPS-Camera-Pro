//
//  ProfileRouter.swift
//  GPS-Camera-Pro
//
//  Created by User on 20/06/26.
//

import SwiftUI

// MARK: - Profile Flow Navigation Enum
enum ProfileFlow: NavigationDestination, Hashable {
    case editProfile
    case settings
    
    var title: String {
        switch self {
        case .editProfile: return "Edit Profile"
        case .settings:    return "Settings"
        }
    }
    
    @ViewBuilder
    var destinationView: some View {
        switch self {
        case .editProfile:
            Text("Edit Profile View")
        case .settings:
            Text("Settings View")
        }
    }
}

// MARK: - Profile Router Flow Type
typealias ProfileRouterFlow = Router<ProfileFlow>
