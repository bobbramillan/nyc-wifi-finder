//
//  WiFiSpotDetailSheet.swift
//  NYCWiFiFinder
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

                if let userLocation {
                    HStack {
                        Image(systemName: "figure.walk")
                            .foregroundColor(.green)
                        Text(userLocation.formattedDistance(to: spot.coordinate))
                            .font(.subheadline)
                            .foregroundColor(.green)
                    }
                }
            }

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
}
