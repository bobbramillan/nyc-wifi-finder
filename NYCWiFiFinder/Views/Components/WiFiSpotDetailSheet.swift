//
//  WiFiSpotDetailSheet.swift
//  NYCWiFiFinder
//
//  Created by Bavanan Bramillan on 12/24/25.
//

import SwiftUI
import CoreLocation

struct WiFiSpotDetailSheet: View {
    let spot: WiFiSpot
    let userLocation: CLLocationCoordinate2D?
    let isBookmarked: Bool
    let onBookmarkToggle: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // WiFi icon at top
            Image(systemName: "wifi")
                .font(.system(size: 40))
                .foregroundColor(.blue)
            
            Text(spot.name)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(.secondary)
                    Text(spot.location)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Image(systemName: "map.fill")
                        .foregroundColor(.blue)
                    Text("\(spot.neighborhood), \(spot.borough)")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                
                if let userLocation = userLocation {
                    let dist = distance(from: userLocation, to: spot.coordinate)
                    HStack {
                        Image(systemName: "figure.walk")
                            .foregroundColor(.green)
                        Text(String(format: "%.0f meters away", dist))
                            .font(.subheadline)
                            .foregroundColor(.green)
                    }
                }
            }
            
            // Bookmark button
            Button(action: onBookmarkToggle) {
                HStack {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                    Text(isBookmarked ? "Saved" : "Save")
                        .fontWeight(.semibold)
                }
                .foregroundColor(isBookmarked ? .yellow : .blue)
                .padding()
                .frame(maxWidth: .infinity)
                .background(isBookmarked ? Color.yellow.opacity(0.2) : Color.blue.opacity(0.1))
                .cornerRadius(10)
            }
            
            Button(action: onDismiss) {
                Text("Close")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
        .presentationDetents([.height(400)])
    }
    
    func distance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return fromLocation.distance(from: toLocation)
    }
}
