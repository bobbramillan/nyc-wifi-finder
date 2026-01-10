//
//  ForYouView.swift
//  NYCWiFiFinder
//
//  Created by Bavanan Bramillan on 12/24/25.
//

import SwiftUI
import CoreLocation

struct ForYouView: View {
    let allWiFiSpots: [WiFiSpot]
    @ObservedObject var locationManager: LocationManager
    @ObservedObject var bookmarkManager: BookmarkManager
    @ObservedObject var visitHistoryManager: VisitHistoryManager
    
    @State private var selectedSpot: WiFiSpot?
    @State private var recommendations: [Recommendation] = []
    
    private let recommendationEngine = RecommendationEngine()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "sparkles")
                                .font(.title)
                                .foregroundColor(.blue)
                            Text("For You")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                        }
                        
                        Text("Personalized WiFi recommendations based on your preferences")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Stats cards
                    if !visitHistoryManager.visitHistory.isEmpty {
                        HStack(spacing: 12) {
                            StatCard(
                                icon: "clock.fill",
                                title: "Visited",
                                value: "\(visitHistoryManager.visitHistory.count)",
                                color: .blue
                            )
                            
                            if let favBorough = visitHistoryManager.mostVisitedBorough() {
                                StatCard(
                                    icon: "map.fill",
                                    title: "Favorite",
                                    value: favBorough,
                                    color: .green
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Recommendations list
                    if recommendations.isEmpty {
                        EmptyRecommendationsView()
                    } else {
                        VStack(spacing: 0) {
                            ForEach(Array(recommendations.enumerated()), id: \.element.spot.id) { index, recommendation in
                                RecommendationCard(
                                    recommendation: recommendation,
                                    rank: index + 1,
                                    userLocation: locationManager.userLocation,
                                    isBookmarked: bookmarkManager.isBookmarked(recommendation.spot),
                                    onTap: {
                                        selectedSpot = recommendation.spot
                                        visitHistoryManager.recordVisit(recommendation.spot)
                                    },
                                    onBookmarkToggle: {
                                        bookmarkManager.toggleBookmark(recommendation.spot)
                                        refreshRecommendations()
                                    }
                                )
                                
                                if index < recommendations.count - 1 {
                                    Divider()
                                        .padding(.leading, 70)
                                }
                            }
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .sheet(item: $selectedSpot) { spot in
                WiFiSpotDetailSheet(
                    spot: spot,
                    userLocation: locationManager.userLocation,
                    isBookmarked: bookmarkManager.isBookmarked(spot),
                    onBookmarkToggle: {
                        bookmarkManager.toggleBookmark(spot)
                        refreshRecommendations()
                    },
                    onDismiss: {
                        selectedSpot = nil
                    }
                )
            }
        }
        .onAppear {
            refreshRecommendations()
        }
        .onChange(of: bookmarkManager.bookmarkedSpotIDs) { _, _ in
            refreshRecommendations()
        }
        .onChange(of: visitHistoryManager.visitHistory) { _, _ in
            refreshRecommendations()
        }
    }
    
    private func refreshRecommendations() {
        recommendations = recommendationEngine.generateRecommendations(
            allSpots: allWiFiSpots,
            bookmarkedSpots: bookmarkManager.bookmarkedSpotIDs,
            visitHistory: visitHistoryManager.visitHistory,
            userLocation: locationManager.userLocation
        )
    }
}

#Preview {
    ForYouView(
        allWiFiSpots: [],
        locationManager: LocationManager(),
        bookmarkManager: BookmarkManager(),
        visitHistoryManager: VisitHistoryManager()
    )
}
