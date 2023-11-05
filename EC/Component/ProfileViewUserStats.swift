//
//  ProfileViewUserStats.swift
//  EC
//
//  Created by Justin Zhang on 11/2/23.
//

import SwiftUI

// Follwer + Following + Likes + Post reused code
struct ProfileViewUserStats: View {
    let value: Int
    let title: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            Text(String(value))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(colorScheme == .light ? .black : .white )
            Text(String(title))
                .font(.footnote)
                .foregroundColor(colorScheme == .light ? .black : .white )
        }
    }
}
