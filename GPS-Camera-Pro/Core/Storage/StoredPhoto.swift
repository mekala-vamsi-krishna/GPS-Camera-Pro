//
//  StoredPhoto.swift
//  GPS-Camera-Pro
//
//  Created by User on 20/06/26.
//

import SwiftData
import Foundation

@Model
final class StoredPhoto {
    @Attribute(.unique) var id: UUID
    var date: Date
    var isFavorite: Bool
    
    var latitude: Double?
    var longitude: Double?
    var locationName: String?
    var subAddress: String?
    
    @Attribute(.externalStorage) var imageData: Data?
    
    init(id: UUID = UUID(), date: Date = Date(), isFavorite: Bool = false, latitude: Double? = nil, longitude: Double? = nil, locationName: String? = nil, subAddress: String? = nil, imageData: Data? = nil) {
        self.id = id
        self.date = date
        self.isFavorite = isFavorite
        self.latitude = latitude
        self.longitude = longitude
        self.locationName = locationName
        self.subAddress = subAddress
        self.imageData = imageData
    }
}
