//
//  BookmarkManager.swift
//  NYCWiFiFinder
//
//  Created by Bavanan Bramillan on 12/24/25.
//

import Foundation
import Combine

class BookmarkManager: ObservableObject {
    @Published var bookmarkedSpotIDs: Set<UUID> = []
    
    private let userDefaultsKey = "bookmarkedSpots"
    
    init() {
        loadBookmarks()
    }
    
    func isBookmarked(_ spot: WiFiSpot) -> Bool {
        bookmarkedSpotIDs.contains(spot.id)
    }
    
    func toggleBookmark(_ spot: WiFiSpot) {
        if bookmarkedSpotIDs.contains(spot.id) {
            bookmarkedSpotIDs.remove(spot.id)
        } else {
            bookmarkedSpotIDs.insert(spot.id)
        }
        saveBookmarks()
    }
    
    private func saveBookmarks() {
        let idStrings = bookmarkedSpotIDs.map { $0.uuidString }
        UserDefaults.standard.set(idStrings, forKey: userDefaultsKey)
    }
    
    private func loadBookmarks() {
        if let idStrings = UserDefaults.standard.array(forKey: userDefaultsKey) as? [String] {
            bookmarkedSpotIDs = Set(idStrings.compactMap { UUID(uuidString: $0) })
        }
    }
}
