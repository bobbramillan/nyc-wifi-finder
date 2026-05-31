//
//  BookmarkManager.swift
//  NYCWiFiFinder
//

import Foundation
import Combine
import UIKit

class BookmarkManager: ObservableObject {
    @Published var bookmarkedSpotIDs: Set<Int> = []

    // A fixed userID for now — replace with real auth later
    private let userID: String = {
        UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
    }()
    private let session = URLSession.shared

    init() {
        Task { await fetchBookmarks() }
    }

    func isBookmarked(_ spot: WiFiSpot) -> Bool {
        bookmarkedSpotIDs.contains(spot.id)
    }

    func toggleBookmark(_ spot: WiFiSpot) {
        if bookmarkedSpotIDs.contains(spot.id) {
            bookmarkedSpotIDs.remove(spot.id)
            Task { await removeBookmark(spot) }
        } else {
            bookmarkedSpotIDs.insert(spot.id)
            Task { await addBookmark(spot) }
        }
    }

    // MARK: - API calls

    private func fetchBookmarks() async {
        guard let url = URL(string: "\(APIConfig.Endpoints.bookmarks)?userID=\(userID)") else { return }

        do {
            let (data, _) = try await session.data(from: url)
            let response = try JSONDecoder().decode(BookmarkListResponse.self, from: data)
            let ids = Set(response.data.map { $0.spotID })
            await MainActor.run { self.bookmarkedSpotIDs = ids }
        } catch {
            print("Failed to fetch bookmarks: \(error)")
        }
    }

    private func addBookmark(_ spot: WiFiSpot) async {
        guard let url = URL(string: APIConfig.Endpoints.bookmarks) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = BookmarkRequest(
            userID: userID,
            spotID: spot.id,
            spotName: spot.name,
            borough: spot.borough,
            neighborhood: spot.neighborhood
        )

        do {
            request.httpBody = try JSONEncoder().encode(body)
            let (_, _) = try await session.data(for: request)
        } catch {
            print("Failed to add bookmark: \(error)")
        }
    }

    private func removeBookmark(_ spot: WiFiSpot) async {
        guard let url = URL(string: "\(APIConfig.Endpoints.bookmarks)/\(spot.id)?userID=\(userID)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        do {
            let (_, _) = try await session.data(for: request)
        } catch {
            print("Failed to remove bookmark: \(error)")
        }
    }
}

// MARK: - Response models

struct BookmarkListResponse: Codable {
    let success: Bool
    let data: [BookmarkRecord]
}

struct BookmarkRecord: Codable {
    let spotID: Int
}

struct BookmarkRequest: Codable {
    let userID: String
    let spotID: Int
    let spotName: String
    let borough: String
    let neighborhood: String
}
