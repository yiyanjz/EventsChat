//
//  FeedFilter.swift
//  EC
//
//  Created by Justin Zhang on 11/2/23.
//

import SwiftUI

enum FeedFilter: Int, CaseIterable {
    case follow
    case explore
    
    var title: String {
        switch self {
        case .follow:
            return "Follow"
        case .explore:
            return "Explore"
        }
    }
}
