//
//  Date + Extension.swift
//  GPS-Camera-Pro
//
//  Created by User on 29/03/26.
//

import Foundation


extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}
