//
//  VisitRecord.swift
//  NYCWiFiFinder
//

import Foundation

struct VisitRecord: Codable, Equatable {
    let spotID: Int
    let spotName: String
    let borough: String
    let neighborhood: String
    let timestamp: Date
}

