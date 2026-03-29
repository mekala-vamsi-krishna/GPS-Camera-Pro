//
//  LocationCardDetailDTO.swift
//  GPS-Camera-Pro
//
//  Created by User on 29/03/26.
//

import Foundation
import UIKit

struct LocationCardDetailDTO {
    let lat: Double
    let long: Double
    let locationName: String
    let subAddress: String
    let dateTime: String
    let logo: String
    let appName: String
    let mapSnapshot: UIImage?
}

extension LocationCardDetailDTO {
    func toDomain() -> LocationCardDetailDomain {
        LocationCardDetailDomain(
            lat: lat,
            long: long,
            locationName: locationName,
            subAddress: subAddress,
            dateTime: dateTime,
            logo: logo,
            appName: appName,
            mapSnapshot: mapSnapshot
        )
    }
}
