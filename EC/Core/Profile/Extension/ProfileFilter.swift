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

// firebase collection filter
enum CollectionFilter: Int, CaseIterable {
    case userLiked
    case userStared
    case userPost
    
    var title: String {
        switch self {
        case .userLiked:
            return "user-likes"
        case .userStared:
            return "user-stars"
        case .userPost:
            return "user-posts"
        }
    }
}

// profile filter section
enum OtherProfileFilter: Int, CaseIterable {
    case posts
    case stars
    
    var title: String {
        switch self {
        case .posts:
            return "Posts"
        case .stars:
            return "Stars"
        }
    }
}

// profile info filter
enum ProfileInfoFilter: Int, CaseIterable {
    case following
    case follower
    
    var title: String {
        switch self {
        case .following:
            return "Following"
        case .follower:
            return "Follower"
        }
    }
}
