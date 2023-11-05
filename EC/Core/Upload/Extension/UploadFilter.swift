//
//  UploadFilter.swift
//  EC
//
//  Created by Justin Zhang on 11/2/23.
//

import SwiftUI

enum UploadFilter: Int, CaseIterable {
    case allItems
    case video
    case photo
    
    var title: String {
        switch self {
        case .allItems:
            return "All"
        case .video:
            return "Video"
        case .photo:
            return "Photo"
        }
    }
}
