//
//  ForYouView.swift
//  NYCWiFiFinder
//

import SwiftUI
import CoreLocation

struct ForYouView: View {
    let allWiFiSpots: [WiFiSpot]
    @ObservedObject var locationManager: LocationManager
    @ObservedObject var bookmarkManager: BookmarkManager
    @ObservedObject var visitHistoryManager: VisitHistoryManager

    @StateObject private var engine = RecommendationEngine()
    @State private var selectedSpot: WiFiSpot?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Stat cards
                    HStack(spacing: 12) {
                        StatCard(
                            icon: "clock",
                            title: "Visited",
                            value: "\(visitHistoryManager.visitHistory.count)",
                            color: .blue
                        )
                        StatCard(
                            icon: "map",
                            title: "Favorite",
                            value: visitHistoryManager.mostVisitedBorough() ?? "—",
                            color: .green
                        )
                    }
                    .padding(.horizontal)

                    // Recommendations
                    if engine.isLoading {
                        VStack(spacing: 12) {
                            ProgressView()
                            Text("Finding spots for you…")
                                .foregroundColor(.secondary)
                                .font(.subheadline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)

                    } else if let error = engine.error {
                        VStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 40))
                                .foregroundColor(.orange)
                            Text("Couldn't load recommendations")
                                .font(.headline)
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            Button("Retry") {
                                Task {
                                    await engine.fetchRecommendations(
                                        userLocation: locationManager.userLocation
                                    )
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)

                    } else if engine.recommendations.isEmpty {
                        EmptyRecommendationsView()

                    } else {
                        VStack(spacing: 12) {
                            ForEach(Array(engine.recommendations.enumerated()), id: \.element.spot.id) { index, rec in
                                RecommendationCard(
                                    recommendation: rec,
                                    rank: index + 1,
                                    userLocation: locationManager.userLocation,
                                    isBookmarked: bookmarkManager.isBookmarked(rec.spot),
                                    onTap: { selectedSpot = rec.spot },
                                    onBookmarkToggle: { bookmarkManager.toggleBookmark(rec.spot) }
                                )
                                .padding(.horizontal)

                                if index < engine.recommendations.count - 1 {
                                    Divider().padding(.horizontal)
                                }
                            }
                        }
                    }
                }
                .padding(.top)
            }
            .navigationTitle("For You")
            .task {
                await engine.fetchRecommendations(userLocation: locationManager.userLocation)
            }
            .onChange(of: bookmarkManager.bookmarkedSpotIDs) { _, _ in
                Task {
                    await engine.fetchRecommendations(userLocation: locationManager.userLocation)
                }
            }
        }
        .sheet(item: $selectedSpot) { spot in
            WiFiSpotDetailSheet(
                spot: spot,
                userLocation: locationManager.userLocation,
                isBookmarked: bookmarkManager.isBookmarked(spot),
                onBookmarkToggle: { bookmarkManager.toggleBookmark(spot) },
                onDismiss: { selectedSpot = nil }
            )
            .onAppear { visitHistoryManager.recordVisit(spot) }
        }
    }
}
