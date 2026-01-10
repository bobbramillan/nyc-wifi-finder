//
//  WiFiService.swift
//  NYCWiFiFinder
//
//  Created by Bavanan Bramillan on 12/24/25.
//

import Foundation
import CoreLocation

class WiFiService {
    func fetchNYCWiFiSpots() async -> [WiFiSpot] {
        // NYC Open Data API for public WiFi hotspots
        let urlString = "https://data.cityofnewyork.us/resource/yjub-udmw.json?$limit=500"
        
        guard let url = URL(string: urlString) else {
            return []
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            let response = try decoder.decode([NYCWiFiResponse].self, from: data)
            
            return response.compactMap { item in
                guard let lat = item.latitude,
                      let lon = item.longitude,
                      let latDouble = Double(lat),
                      let lonDouble = Double(lon) else {
                    return nil
                }
                
                let boroughName = mapBoroughCode(item.borough)
                
                return WiFiSpot(
                    name: item.name ?? "Public WiFi",
                    location: item.location ?? "NYC",
                    borough: boroughName,
                    neighborhood: item.ntaname ?? "Unknown",
                    coordinate: CLLocationCoordinate2D(latitude: latDouble, longitude: lonDouble)
                )
            }
        } catch {
            print("Error fetching WiFi data: \(error)")
            return []
        }
    }
    
    private func mapBoroughCode(_ code: String?) -> String {
        guard let code = code else { return "Unknown" }
        
        switch code {
        case "1": return "Manhattan"
        case "2": return "The Bronx"
        case "3": return "Brooklyn"
        case "4": return "Queens"
        case "5": return "Staten Island"
        default: return "Unknown"
        }
    }
}

struct NYCWiFiResponse: Codable {
    let name: String?
    let location: String?
    let latitude: String?
    let longitude: String?
    let borough: String?
    let ntaname: String?
}
