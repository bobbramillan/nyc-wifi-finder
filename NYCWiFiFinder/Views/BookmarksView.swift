//
//  BookmarksView.swift
//  NYCWiFiFinder
//
//  Created by Bavanan Bramillan on 12/24/25.
//

import SwiftUI
import MapKit

struct BookmarksView: View {
    let allWiFiSpots: [WiFiSpot]
    @ObservedObject var locationManager: LocationManager
    @ObservedObject var bookmarkManager: BookmarkManager
    
    @State private var selectedSpot: WiFiSpot?
    
    var bookmarkedSpots: [WiFiSpot] {
        allWiFiSpots.filter { bookmarkManager.isBookmarked($0) }
    }
    
    var body: some View {
        NavigationView {
            Group {
                if bookmarkedSpots.isEmpty {
                    // Empty state
                    VStack(spacing: 20) {
                        Image(systemName: "bookmark.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Saved WiFi Spots")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Bookmark your favorite WiFi spots from the map to see them here")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                } else {
                    List {
                        ForEach(bookmarkedSpots) { spot in
                            Button(action: {
                                selectedSpot = spot
                            }) {
                                BookmarkRow(
                                    spot: spot,
                                    userLocation: locationManager.userLocation,
                                    isBookmarked: true,
                                    onBookmarkToggle: {
                                        bookmarkManager.toggleBookmark(spot)
                                    }
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Bookmarks")
            .sheet(item: $selectedSpot) { spot in
                WiFiSpotDetailSheet(
                    spot: spot,
                    userLocation: locationManager.userLocation,
                    isBookmarked: bookmarkManager.isBookmarked(spot),
                    onBookmarkToggle: {
                        bookmarkManager.toggleBookmark(spot)
                    },
                    onDismiss: {
                        selectedSpot = nil
                    }
                )
            }
        }
    }
}
