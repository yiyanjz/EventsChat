//
//  Story.swift
//  EC
//
//  Created by Justin Zhang on 11/30/23.
//

import SwiftUI

struct Story:  Identifiable, Hashable, Encodable {
    let id: String
    var caption: String
    var selectedMedia: [String]
    var selectedCover: String
}
