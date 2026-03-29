//
//  LocationCardDetailDTO.swift
//  GPS-Camera-Pro
//
//  Created by User on 29/03/26.
//

import Foundation
struct LocationCardDetailDTO {
    let lat:Double
    let long:Double
    let locationName:String
    let date:String
    let time:String
    let logo:String
    let appName:String
}

extension LocationCardDetailDTO {
    func toDomain() -> LocationCardDetailDomain {
        LocationCardDetailDomain(lat: lat, long: long, locationName: locationName, date: date, time: time, logo: logo, appName: appName)
    }
}
