//
//  ProfileFilter.swift
//  EC
//
//  Created by Justin Zhang on 11/2/23.
//

import SwiftUI

// profile filter section
enum ProfileFilter: Int, CaseIterable {
    case posts
    case likes
    case stars
    
    var title: String {
        switch self {
        case .posts:
            return "Posts"
        case .likes:
            return "Likes"
        case .stars:
            return "Stars"
        }
    }
}

