//
//  FavouritesRouter.swift
//  GPS-Camera-Pro
//
//  Created by User on 20/06/26.
//

import SwiftUI

// MARK: - Favourites Flow Navigation Enum
enum FavouritesFlow: NavigationDestination, Hashable {
    case detail(StoredPhoto)
    
    var title: String {
        switch self {
        case .detail: return "Favorite Detail"
        }
    }
    
    @ViewBuilder
    var destinationView: some View {
        switch self {
        case .detail(let photo):
            PhotoDetailView(photo: photo)
        }
    }
}

// MARK: - Favourites Router Flow Type
typealias FavouritesRouterFlow = Router<FavouritesFlow>
