//
//  APIConfig.swift
//  NYCWiFiFinder
//

import Foundation

enum APIConfig {
    static let baseURL = "http://localhost:3000/api"

    enum Endpoints {
        static let wifi = "\(baseURL)/wifi"
        static let bookmarks = "\(baseURL)/bookmarks"
    }
}
