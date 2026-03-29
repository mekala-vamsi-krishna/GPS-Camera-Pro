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
    
    var title: String {
        switch self {
        case .detailHome:
            return "Detail"
        
        }
    }

    @ViewBuilder
    var destinationView: some View {
        switch self {
        case .detailHome:
            HomeDetailView()
      
        }
    }
}

// MARK: - Home Router Flow Type
typealias HomeRouterFlow = Router<HomeFlow>
