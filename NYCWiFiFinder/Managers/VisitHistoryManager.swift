//
//  VisitHistoryManager.swift
//  NYCWiFiFinder
//

import Foundation
import Combine

class VisitHistoryManager: ObservableObject {
    @Published var visitHistory: [VisitRecord] = []

    private let userDefaultsKey = "visitHistory"

    init() {
        loadHistory()
    }

    func recordVisit(_ spot: WiFiSpot) {
        let record = VisitRecord(
            spotID: spot.id,
            spotName: spot.name,
            borough: spot.borough,
            neighborhood: spot.neighborhood,
            timestamp: Date()
        )
        visitHistory.insert(record, at: 0)

        if visitHistory.count > 50 {
            visitHistory = Array(visitHistory.prefix(50))
        }

        saveHistory()
    }

    func visitCount(for spot: WiFiSpot) -> Int {
        visitHistory.filter { $0.spotID == spot.id }.count
    }

    func mostVisitedBorough() -> String? {
        let boroughs = visitHistory.map { $0.borough }
        return Dictionary(grouping: boroughs, by: { $0 })
            .mapValues { $0.count }
            .max(by: { $0.value < $1.value })?.key
    }

    func mostVisitedNeighborhood() -> String? {
        let neighborhoods = visitHistory.map { $0.neighborhood }
        return Dictionary(grouping: neighborhoods, by: { $0 })
            .mapValues { $0.count }
            .max(by: { $0.value < $1.value })?.key
    }

    private func saveHistory() {
        if let encoded = try? JSONEncoder().encode(visitHistory) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }

    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([VisitRecord].self, from: data) {
            visitHistory = decoded
        }
    }
}
