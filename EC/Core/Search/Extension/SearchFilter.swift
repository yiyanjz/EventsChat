//
//  SearchFilter.swift
//  EC
//
//  Created by Justin Zhang on 11/10/23.
//

import SwiftUI

// profile filter section
enum SearchFilter: Int, CaseIterable {
    case all
    case users
    
    var title: String {
        switch self {
        case .all:
            return "Media"
        case .users:
            return "User"
        }
    }
    
    var index: Int {
        switch self {
        case .all:
            return 0
        case .users:
            return 1
        }
    }
}

