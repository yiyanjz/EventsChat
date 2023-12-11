//
//  User.swift
//  EC
//
//  Created by Justin Zhang on 11/2/23.
//

import SwiftUI

struct User: Identifiable, Codable, Hashable {
    let id: String
    let email: String
    var username: String
    var profileImageUrl: String?
    var fullname: String?
    var bio: String?
    var link: String?
    var gender: String?
    var backgroundImageUrl: String?
    var likes: Int?
    var followers: Int?
    var followering: Int?
    var posts: Int?
}

// dummy data
extension User {
    static var MOCK_USERS: [User] = [
        .init(id: NSUUID().uuidString, email: "Justin@gmail.com", username: "YiyanZhang", profileImageUrl: "", fullname: "Yiyan Zhang", bio: "Bio", link: "eventchat.com", gender: "Male", backgroundImageUrl: "background"),
        .init(id: NSUUID().uuidString, email: "Hannah@gmail.com", username: "HannahZhang"),
        .init(id: NSUUID().uuidString, email: "Liqi@gmail.com", username: "Liqi"),
        .init(id: NSUUID().uuidString, email: "Ben@gmail.com", username: "BenZhang"),
        .init(id: NSUUID().uuidString, email: "Jun@gmail.com", username: "JunLu"),
        .init(id: NSUUID().uuidString, email: "Jackie@gmail.com", username: "JackieLiang")
    ]
}
