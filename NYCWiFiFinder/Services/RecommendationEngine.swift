//
//  RecommendationEngine.swift
//  NYCWiFiFinder
//

import Foundation
import CoreLocation
import Combine
import UIKit

struct APIRecommendation: Codable {
    let spotID: Int
    let name: String
    let location: String
    let borough: String
    let neighborhood: String
    let latitude: Double
    let longitude: Double
    let score: Int
    let reason: String
}

struct RecommendationResponse: Codable {
    let success: Bool
    let count: Int
    let data: [APIRecommendation]
}

struct RecommendationRequest: Codable {
    let userID: String
    let latitude: Double?
    let longitude: Double?
}

class RecommendationEngine: ObservableObject {
    @Published var recommendations: [Recommendation] = []
    @Published var isLoading: Bool = false
    @Published var error: String? = nil

    private let userID: String = {
        UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
    }()

    func fetchRecommendations(userLocation: CLLocationCoordinate2D?) async {
        await MainActor.run { isLoading = true; error = nil }

        guard let url = URL(string: "\(APIConfig.baseURL)/recommendations") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = RecommendationRequest(
            userID: userID,
            latitude: userLocation?.latitude,
            longitude: userLocation?.longitude
        )

        do {
            request.httpBody = try JSONEncoder().encode(body)
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(RecommendationResponse.self, from: data)

            let mapped = response.data.map { item in
                Recommendation(
                    spot: WiFiSpot(
                        id: item.spotID,
                        name: item.name,
                        location: item.location,
                        borough: item.borough,
                        neighborhood: item.neighborhood,
                        latitude: item.latitude,
                        longitude: item.longitude
                    ),
                    score: Double(item.score),
                    reasons: [item.reason]
                )
            }

            await MainActor.run {
                self.recommendations = mapped
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}
