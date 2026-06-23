//
//  CapturedPhoto.swift
//  GPS-Camera-Pro
//
//  Created by User on 20/06/26.
//

import UIKit

struct CapturedPhoto: Hashable {
    let id: UUID = UUID()
    let image: UIImage
    let location: LocationCardDetailDomain?
    
    static func == (lhs: CapturedPhoto, rhs: CapturedPhoto) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
