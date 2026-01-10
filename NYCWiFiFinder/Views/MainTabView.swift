//
//  MainTabView.swift
//  NYCWiFiFinder
//
//  Created by Bavanan Bramillan on 12/24/25.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var bookmarkManager = BookmarkManager()
    @StateObject private var visitHistoryManager = VisitHistoryManager()
    @StateObject private var locationManager = LocationManager()
    @State private var allWiFiSpots: [WiFiSpot] = []
    private let wifiService = WiFiService()
    
    var body: some View {
        TabView {
            MapView(
                allWiFiSpots: $allWiFiSpots,
                locationManager: locationManager,
                bookmarkManager: bookmarkManager,
                visitHistoryManager: visitHistoryManager
            )
            .tabItem {
                Label("Map", systemImage: "map.fill")
            }
            
            ForYouView(
                allWiFiSpots: allWiFiSpots,
                locationManager: locationManager,
                bookmarkManager: bookmarkManager,
                visitHistoryManager: visitHistoryManager
            )
            .tabItem {
                Label("For You", systemImage: "sparkles")
            }
            
            BookmarksView(
                allWiFiSpots: allWiFiSpots,
                locationManager: locationManager,
                bookmarkManager: bookmarkManager
            )
            .tabItem {
                Label("Bookmarks", systemImage: "bookmark.fill")
            }
        }
        .task {
            allWiFiSpots = await wifiService.fetchNYCWiFiSpots()
        }
    }
}

#Preview {
    MainTabView()
}

