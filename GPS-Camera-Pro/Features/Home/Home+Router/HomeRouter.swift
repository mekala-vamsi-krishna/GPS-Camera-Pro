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
    
    var title: String {
        switch self {
        case .detailHome:
            return "Detail"
        
        case .helpView:
            return "Help view"
        
        }
    }

    @ViewBuilder
    var destinationView: some View {
        switch self {
        case .detailHome:
            HomeDetailView()
            
        case .helpView:
            Text("Help View")
      
        }
    }
}

// MARK: - Home Router Flow Type
typealias HomeRouterFlow = Router<HomeFlow>
