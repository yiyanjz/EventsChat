//
//  Post.swift
//  EC
//
//  Created by Justin Zhang on 11/2/23.
//

import SwiftUI
import Firebase

struct Post: Identifiable, Codable, Hashable {
    let id: String
    var caption: String
    var title: String
    var likes: Int
    var stars: Int
    var comments: Int
    var timestamp: Timestamp
    var user: User?
    var imagesUrl: [String]
    var ownerId: String?
    var didLike: Bool? = false
    var didStar: Bool? = false
    var userLiked: [String]? = []
}


// dummy data
extension Post {
    static var MOCK_POST: [Post] = [
        .init(id: NSUUID().uuidString, caption: "first", title: "so cheap", likes: 0, stars: 0, comments: 0, timestamp: Timestamp(date: Date()), user: User.MOCK_USERS[0], imagesUrl: ["shin", "jian"]),
        .init(id: NSUUID().uuidString, caption: "secondsecfaasfas", title: "so cheapso cheapso cheapso cheap", likes: 0, stars: 0, comments: 0, timestamp: Timestamp(date: Date()), user: User.MOCK_USERS[1],  imagesUrl: ["jian","shin","ni"]),
        .init(id: NSUUID().uuidString, caption: "third", title: "so cheapso cheapso cheapso cheapso cheapso cheapso cheap", likes: 0, stars: 0, comments: 0, timestamp: Timestamp(date: Date()), user: User.MOCK_USERS[2], imagesUrl: ["ni"]),
        .init(id: NSUUID().uuidString, caption: "fourthasafasfasf", title: "fasdfasdfadsf", likes: 0, stars: 0, comments: 0, timestamp: Timestamp(date: Date()), user: User.MOCK_USERS[3], imagesUrl: ["ni"]),
        .init(id: NSUUID().uuidString, caption: "firstafasfs", title: "so cheap", likes: 0, stars: 0, comments: 0, timestamp: Timestamp(date: Date()), user: User.MOCK_USERS[0], imagesUrl: ["shin"]),
        .init(id: NSUUID().uuidString, caption: "second", title: "so cheapso cheapso cheapso cheap", likes: 0, stars: 0, comments: 0, timestamp: Timestamp(date: Date()), user: User.MOCK_USERS[1],  imagesUrl: ["jian"]),
        .init(id: NSUUID().uuidString, caption: "first", title: "so cheap", likes: 0, stars: 0, comments: 0, timestamp: Timestamp(date: Date()), user: User.MOCK_USERS[0], imagesUrl: ["shin"]),
        .init(id: NSUUID().uuidString, caption: "second", title: "so cheapso cheapso cheapso cheap", likes: 0, stars: 0, comments: 0, timestamp: Timestamp(date: Date()), user: User.MOCK_USERS[1],  imagesUrl: ["jian"]),
    ]
}
