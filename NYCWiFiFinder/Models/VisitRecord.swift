//
//  VisitRecord.swift
//  NYCWiFiFinder
//
//  Created by Bavanan Bramillan on 12/24/25.
//

import Foundation

struct VisitRecord: Codable, Equatable {
    let spotID: UUID
    let spotName: String
    let borough: String
    let neighborhood: String
    let timestamp: Date
}

