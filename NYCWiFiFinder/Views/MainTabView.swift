//
//  MainTabView.swift
//  NYCWiFiFinder
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var bookmarkManager = BookmarkManager()
    @StateObject private var visitHistoryManager = VisitHistoryManager()
    @StateObject private var locationManager = LocationManager()

    @State private var allWiFiSpots: [WiFiSpot] = []
    @State private var loadingState: LoadingState = .idle

    private let wifiService = WiFiService()

    enum LoadingState {
        case idle, loading, loaded, failed(String)
    }

    var body: some View {
        Group {
            switch loadingState {
            case .idle, .loading:
                VStack(spacing: 16) {
                    ProgressView()
                    Text("Loading NYC WiFi spots…")
                        .foregroundColor(.secondary)
                }

            case .failed(let message):
                VStack(spacing: 16) {
                    Image(systemName: "wifi.exclamationmark")
                        .font(.system(size: 50))
                        .foregroundColor(.red)
                    Text("Couldn't load WiFi spots")
                        .font(.title3).fontWeight(.semibold)
                    Text(message)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    Button("Retry") {
                        Task { await loadSpots() }
                    }
                    .buttonStyle(.borderedProminent)
                }

            case .loaded:
                TabView {
                    MapView(
                        allWiFiSpots: $allWiFiSpots,
                        locationManager: locationManager,
                        bookmarkManager: bookmarkManager,
                        visitHistoryManager: visitHistoryManager
                    )
                    .tabItem { Label("Map", systemImage: "map.fill") }

                    ForYouView(
                        allWiFiSpots: allWiFiSpots,
                        locationManager: locationManager,
                        bookmarkManager: bookmarkManager,
                        visitHistoryManager: visitHistoryManager
                    )
                    .tabItem { Label("For You", systemImage: "sparkles") }

                    BookmarksView(
                        allWiFiSpots: allWiFiSpots,
                        locationManager: locationManager,
                        bookmarkManager: bookmarkManager
                    )
                    .tabItem { Label("Bookmarks", systemImage: "bookmark.fill") }
                }
            }
        }
        .task { await loadSpots() }
    }

    private func loadSpots() async {
        loadingState = .loading
        do {
            allWiFiSpots = try await wifiService.fetchNYCWiFiSpots()
            loadingState = .loaded
        } catch {
            loadingState = .failed(error.localizedDescription)
        }
    }
}

#Preview {
    MainTabView()
}

