//
//  WiFiSpot.swift
//  NYCWiFiFinder
//
//  Created by Bavanan Bramillan on 12/24/25.
//

import Foundation
import CoreLocation

struct WiFiSpot: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let location: String
    let borough: String
    let neighborhood: String
    let coordinate: CLLocationCoordinate2D
    
    static func == (lhs: WiFiSpot, rhs: WiFiSpot) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
