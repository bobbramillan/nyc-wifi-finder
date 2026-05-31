//
//  WiFiService.swift
//  NYCWiFiFinder
//

import Foundation

enum WiFiServiceError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
}

class WiFiService {
    func fetchNYCWiFiSpots() async throws -> [WiFiSpot] {
        guard let url = URL(string: APIConfig.Endpoints.wifi) else {
            throw WiFiServiceError.invalidURL
        }

        let data: Data
        do {
            let (fetched, _) = try await URLSession.shared.data(from: url)
            data = fetched
        } catch {
            throw WiFiServiceError.networkError(error)
        }

        do {
            let response = try JSONDecoder().decode(WiFiAPIResponse.self, from: data)
            return response.data
        } catch {
            throw WiFiServiceError.decodingError(error)
        }
    }
}

// Matches the { success, count, data } shape our backend returns
struct WiFiAPIResponse: Codable {
    let success: Bool
    let count: Int
    let data: [WiFiSpot]
}
