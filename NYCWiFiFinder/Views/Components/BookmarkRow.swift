//
//  BookmarkRow.swift
//  NYCWiFiFinder
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

                if let userLocation {
                    HStack(spacing: 4) {
                        Image(systemName: "figure.walk")
                            .font(.caption)
                            .foregroundColor(.green)
                        Text(userLocation.formattedDistance(to: spot.coordinate))
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }

            Spacer()

            Button(action: onBookmarkToggle) {
                Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                    .font(.title3)
                    .foregroundColor(.yellow)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 8)
    }
}
