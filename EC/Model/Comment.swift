//
//  Comment.swift
//  EC
//
//  Created by Justin Zhang on 12/9/23.
//

import SwiftUI
import Firebase


// Comment Temp Model
struct Comment: Identifiable, Codable, Hashable {
    let id: String
    var caption: String
    var likes: Int
    var comments: Int
    var timestamp: Timestamp
    var ownerId: String
    var didLike: Bool? = false
    var user: User?
    var replies: [Comment]?
}
