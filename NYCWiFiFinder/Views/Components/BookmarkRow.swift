//
//  BookmarkRow.swift
//  NYCWiFiFinder
//
//  Created by Bavanan Bramillan on 12/24/25.
//

import SwiftUI
import CoreLocation

struct BookmarkRow: View {
    let spot: WiFiSpot
    let userLocation: CLLocationCoordinate2D?
    let isBookmarked: Bool
    let onBookmarkToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // WiFi icon
            Image(systemName: "wifi")
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40, height: 40)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(spot.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(spot.neighborhood)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if let userLocation = userLocation {
                    let dist = distance(from: userLocation, to: spot.coordinate)
                    HStack(spacing: 4) {
                        Image(systemName: "figure.walk")
                            .font(.caption)
                            .foregroundColor(.green)
                        Text(String(format: "%.1f km away", dist / 1000))
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }
            
            Spacer()
            
            // Bookmark button
            Button(action: onBookmarkToggle) {
                Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                    .font(.title3)
                    .foregroundColor(.yellow)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 8)
    }
    
    func distance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return fromLocation.distance(from: toLocation)
    }
}
