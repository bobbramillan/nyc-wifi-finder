//
//  RecommendationEngine.swift
//  NYCWiFiFinder
//
//  Created by Bavanan Bramillan on 12/24/25.
//

import Foundation
import CoreLocation

class RecommendationEngine {
    
    func generateRecommendations(
        allSpots: [WiFiSpot],
        bookmarkedSpots: Set<UUID>,
        visitHistory: [VisitRecord],
        userLocation: CLLocationCoordinate2D?
    ) -> [Recommendation] {
        
        var recommendations: [Recommendation] = []
        
        // Get user preferences from history
        let preferredBorough = mostFrequent(visitHistory.map { $0.borough })
        let preferredNeighborhood = mostFrequent(visitHistory.map { $0.neighborhood })
        
        for spot in allSpots {
            // Skip already bookmarked spots
            if bookmarkedSpots.contains(spot.id) {
                continue
            }
            
            var score: Double = 0
            var reasons: [String] = []
            
            // 1. Proximity score (40% weight)
            if let userLocation = userLocation {
                let distance = calculateDistance(from: userLocation, to: spot.coordinate)
                let proximityScore = max(0, 1 - (distance / 5000)) // Within 5km gets high score
                score += proximityScore * 40
                
                if distance < 1000 {
                    reasons.append("Very close to you (\(Int(distance))m)")
                } else if distance < 2000 {
                    reasons.append("Nearby (\(String(format: "%.1f", distance/1000))km)")
                }
            }
            
            // 2. Borough preference (25% weight)
            if let preferredBorough = preferredBorough, spot.borough == preferredBorough {
                score += 25
                reasons.append("In your favorite borough: \(spot.borough)")
            }
            
            // 3. Neighborhood preference (20% weight)
            if let preferredNeighborhood = preferredNeighborhood, spot.neighborhood == preferredNeighborhood {
                score += 20
                reasons.append("In \(spot.neighborhood) - you visit here often")
            }
            
            // 4. Similar to bookmarked spots (15% weight)
            let bookmarkedBoroughs = allSpots.filter { bookmarkedSpots.contains($0.id) }.map { $0.borough }
            if bookmarkedBoroughs.contains(spot.borough) {
                score += 15
                reasons.append("Similar to your saved spots")
            }
            
            // Only recommend if score is meaningful
            if score > 20 || !reasons.isEmpty {
                recommendations.append(Recommendation(spot: spot, score: score, reasons: reasons))
            }
        }
        
        // Sort by score and return top 10
        return recommendations.sorted { $0.score > $1.score }.prefix(10).map { $0 }
    }
    
    private func mostFrequent(_ items: [String]) -> String? {
        guard !items.isEmpty else { return nil }
        let counts = Dictionary(grouping: items, by: { $0 }).mapValues { $0.count }
        return counts.max(by: { $0.value < $1.value })?.key
    }
    
    private func calculateDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return fromLocation.distance(from: toLocation)
    }
}
