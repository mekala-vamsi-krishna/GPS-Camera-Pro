//
//  AllPhotosRouter.swift
//  GPS-Camera-Pro
//
//  Created by User on 20/06/26.
//

import SwiftUI

// MARK: - AllPhotos Flow Navigation Enum
enum AllPhotosFlow: NavigationDestination, Hashable {
    case detail
    
    var title: String {
        switch self {
        case .detail: return "Photo Detail"
        }
    }
    
    @ViewBuilder
    var destinationView: some View {
        switch self {
        case .detail:
            Text("Photo Detail View")
        }
    }
}

// MARK: - AllPhotos Router Flow Type
typealias AllPhotosRouterFlow = Router<AllPhotosFlow>
