//
//  EmptyRecommendationsView.swift
//  NYCWiFiFinder
//
//  Created by Bavanan Bramillan on 12/24/25.
//

import SwiftUI

struct EmptyRecommendationsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Start Exploring!")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Visit and bookmark WiFi spots to get personalized recommendations")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding(.top, 60)
    }
}
