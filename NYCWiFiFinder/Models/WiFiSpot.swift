//
//  WiFiSpot.swift
//  NYCWiFiFinder
//

import Foundation
import CoreLocation

struct WiFiSpot: Identifiable, Hashable, Codable {
    let id: Int
    let name: String
    let location: String
    let borough: String
    let neighborhood: String
    let latitude: Double
    let longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
