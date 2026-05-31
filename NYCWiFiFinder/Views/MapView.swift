//
//  MapView.swift
//  NYCWiFiFinder
//

import SwiftUI
import MapKit

struct MapView: View {
    @Binding var allWiFiSpots: [WiFiSpot]
    @ObservedObject var locationManager: LocationManager
    @ObservedObject var bookmarkManager: BookmarkManager
    @ObservedObject var visitHistoryManager: VisitHistoryManager

    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 40.7180, longitude: -73.9870),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )

    @State private var selectedBorough: String = ""
    @State private var selectedNeighborhood: String = "All"
    @State private var selectedSpot: WiFiSpot?

    var availableBoroughs: [String] {
        Set(allWiFiSpots.map { $0.borough }).sorted()
    }

    var availableNeighborhoods: [String] {
        let hoods = Set(allWiFiSpots.filter { $0.borough == selectedBorough }.map { $0.neighborhood })
        return ["All"] + hoods.sorted()
    }

    var filteredSpots: [WiFiSpot] {
        var spots = allWiFiSpots.filter { $0.borough == selectedBorough }
        if selectedNeighborhood != "All" {
            spots = spots.filter { $0.neighborhood == selectedNeighborhood }
        }
        return spots
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // Filter UI
                VStack(spacing: 12) {
                    HStack {
                        Text("Filter WiFi Spots")
                            .font(.headline)
                        Spacer()
                    }

                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Borough")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Picker("Borough", selection: $selectedBorough) {
                                ForEach(availableBoroughs, id: \.self) { Text($0).tag($0) }
                            }
                            .pickerStyle(.menu)
                            .tint(.blue)
                            .onChange(of: selectedBorough) { _, newValue in
                                selectedNeighborhood = "All"
                                moveToBorough(newValue)
                            }
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Neighborhood")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Picker("Neighborhood", selection: $selectedNeighborhood) {
                                ForEach(availableNeighborhoods, id: \.self) { Text($0).tag($0) }
                            }
                            .pickerStyle(.menu)
                            .tint(.blue)
                        }
                    }

                    HStack {
                        Image(systemName: "wifi")
                            .foregroundColor(.blue)
                        Text("\(filteredSpots.count) hotspots found")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 5, y: 2)

                Map(position: $position, selection: $selectedSpot) {
                    ForEach(filteredSpots) { spot in
                        Marker(spot.name, coordinate: spot.coordinate)
                            .tint(bookmarkManager.isBookmarked(spot) ? .yellow : .blue)
                            .tag(spot)
                    }

                    if let userLocation = locationManager.userLocation {
                        Annotation("You", coordinate: userLocation) {
                            Circle()
                                .fill(.blue)
                                .frame(width: 20, height: 20)
                                .overlay(Circle().stroke(.white, lineWidth: 3))
                        }
                    }
                }
                .ignoresSafeArea(edges: .bottom)
            }

            if selectedSpot == nil {
                Button(action: findNearestWiFi) {
                    HStack {
                        Image(systemName: "location.fill")
                        Text("Find Nearest WiFi")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
                }
                .padding(.bottom, 40)
            }
        }
        .sheet(item: $selectedSpot) { spot in
            WiFiSpotDetailSheet(
                spot: spot,
                userLocation: locationManager.userLocation,
                isBookmarked: bookmarkManager.isBookmarked(spot),
                onBookmarkToggle: { bookmarkManager.toggleBookmark(spot) },
                onDismiss: { selectedSpot = nil }
            )
            .onAppear { visitHistoryManager.recordVisit(spot) }
        }
        // Set a real default once data loads
        .onChange(of: allWiFiSpots) { _, spots in
            if selectedBorough.isEmpty, let first = spots.map({ $0.borough }).sorted().first {
                selectedBorough = first
                moveToBorough(first)
            }
        }
    }

    func moveToBorough(_ borough: String) {
        let coords: [String: (lat: Double, lon: Double, span: Double)] = [
            "Manhattan":    (40.7831, -73.9712, 0.12),
            "The Bronx":    (40.8448, -73.8648, 0.12),
            "Brooklyn":     (40.6782, -73.9442, 0.12),
            "Queens":       (40.7282, -73.7949, 0.15),
            "Staten Island":(40.5795, -74.1502, 0.12)
        ]
        if let c = coords[borough] {
            withAnimation {
                position = .region(MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: c.lat, longitude: c.lon),
                    span: MKCoordinateSpan(latitudeDelta: c.span, longitudeDelta: c.span)
                ))
            }
        }
    }

    func findNearestWiFi() {
        guard let userLocation = locationManager.userLocation else { return }
        if let nearest = filteredSpots.min(by: {
            userLocation.distance(to: $0.coordinate) < userLocation.distance(to: $1.coordinate)
        }) {
            withAnimation {
                position = .region(MKCoordinateRegion(
                    center: nearest.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                ))
            }
        }
    }
}
