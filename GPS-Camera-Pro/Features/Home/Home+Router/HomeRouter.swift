//
//  HomeRouter.swift
//  GPS-Camera-Pro
//
//  Created by User on 29/03/26.
//

import Foundation
import SwiftUI

// MARK: - Home Flow Navigation Enum
enum HomeFlow: NavigationDestination, Hashable {
    case detailHome
    case helpView
    case confirmPhoto(CapturedPhoto)
    
    var title: String {
        switch self {
        case .detailHome:
            return "Detail"
        
        case .helpView:
            return "Help view"
            
        case .confirmPhoto:
            return "Confirm Photo"
        
        }
    }

    @ViewBuilder
    var destinationView: some View {
        switch self {
        case .detailHome:
            HomeDetailView()
            
        case .helpView:
            Text("Help View")
            
        case .confirmPhoto(let captured):
            PhotoConfirmView(capturedPhoto: captured)
      
        }
    }
}

// MARK: - Home Router Flow Type
typealias HomeRouterFlow = Router<HomeFlow>
