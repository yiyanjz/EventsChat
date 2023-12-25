//
//  StoryFilter.swift
//  EC
//
//  Created by Justin Zhang on 12/25/23.
//

import SwiftUI

enum StoryFilter: Int, CaseIterable {
    case stories
    case library
    
    var title: String {
        switch self {
        case .stories:
            return "Stories"
        case .library:
            return "Library"
        }
    }
}
