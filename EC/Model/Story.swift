//
//  Story.swift
//  EC
//
//  Created by Justin Zhang on 11/30/23.
//

import SwiftUI
import Firebase

struct Story:  Identifiable, Hashable, Encodable, Decodable {
    let id: String
    var caption: String
    var selectedMedia: [String]
    var selectedCover: String
    var timestamp: Timestamp
}

extension Story {
    static var MOCK_STORY: [Story] = [
        .init(id: UUID().uuidString, caption: "fsdf", selectedMedia: ["shin"], selectedCover: "shn", timestamp: Timestamp())
    ]
}
