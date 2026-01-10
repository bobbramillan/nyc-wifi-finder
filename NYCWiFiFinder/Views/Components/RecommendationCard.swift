//
//  RecommendationCard.swift
//  NYCWiFiFinder
//
//  Created by Bavanan Bramillan on 12/24/25.
//

import SwiftUI
import CoreLocation

struct RecommendationCard: View {
    let recommendation: Recommendation
    let rank: Int
    let userLocation: CLLocationCoordinate2D?
    let isBookmarked: Bool
    let onTap: () -> Void
    let onBookmarkToggle: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 12) {
                // Rank badge
                ZStack {
                    Circle()
                        .fill(rankColor)
                        .frame(width: 36, height: 36)
                    
                    Text("\(rank)")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    // Spot name
                    Text(recommendation.spot.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    // Location
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(recommendation.spot.neighborhood), \(recommendation.spot.borough)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Distance
                    if let userLocation = userLocation {
                        let dist = calculateDistance(from: userLocation, to: recommendation.spot.coordinate)
                        HStack(spacing: 4) {
                            Image(systemName: "figure.walk")
                                .font(.caption)
                                .foregroundColor(.green)
                            Text(dist < 1000 ? "\(Int(dist))m away" : String(format: "%.1f km away", dist / 1000))
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                    
                    // AI reasons
                    if !recommendation.reasons.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(recommendation.reasons.prefix(2), id: \.self) { reason in
                                HStack(spacing: 4) {
                                    Image(systemName: "sparkle")
                                        .font(.caption2)
                                        .foregroundColor(.blue)
                                    Text(reason)
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .padding(8)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    // Match score
                    HStack(spacing: 4) {
                        Text("\(Int(recommendation.score))% match")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue)
                            .cornerRadius(4)
                    }
                }
                
                Spacer()
                
                // Bookmark button
                Button(action: onBookmarkToggle) {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .font(.title3)
                        .foregroundColor(isBookmarked ? .yellow : .gray)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var rankColor: Color {
        switch rank {
        case 1: return .green
        case 2: return .blue
        case 3: return .orange
        default: return .gray
        }
    }
    
    private func calculateDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return fromLocation.distance(from: toLocation)
    }
}

