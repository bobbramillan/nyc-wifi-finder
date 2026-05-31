//
//  RecommendationCard.swift
//  NYCWiFiFinder
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
                ZStack {
                    Circle()
                        .fill(rankColor)
                        .frame(width: 36, height: 36)
                    Text("\(rank)")
                        .font(.headline)
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(recommendation.spot.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)

                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(recommendation.spot.neighborhood), \(recommendation.spot.borough)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    if let userLocation {
                        HStack(spacing: 4) {
                            Image(systemName: "figure.walk")
                                .font(.caption)
                                .foregroundColor(.green)
                            Text(userLocation.formattedDistance(to: recommendation.spot.coordinate))
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }

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

                    Text("\(Int(recommendation.score))% match")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue)
                        .cornerRadius(4)
                }

                Spacer()

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
}

