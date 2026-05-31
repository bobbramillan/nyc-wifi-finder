//
//  CLLocationCoordinate2D+Extensions.swift
//  NYCWiFiFinder
//

import CoreLocation

extension CLLocationCoordinate2D {
    /// Returns the distance in meters between two coordinates.
    func distance(to other: CLLocationCoordinate2D) -> Double {
        CLLocation(latitude: latitude, longitude: longitude)
            .distance(from: CLLocation(latitude: other.latitude, longitude: other.longitude))
    }

    /// Returns a human-readable distance string (e.g. "350m" or "1.2 km").
    func formattedDistance(to other: CLLocationCoordinate2D) -> String {
        let meters = distance(to: other)
        return meters < 1000
            ? "\(Int(meters))m away"
            : String(format: "%.1f km away", meters / 1000)
    }
}
