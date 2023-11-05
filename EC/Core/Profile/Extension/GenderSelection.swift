//
//  GenderSelection.swift
//  EC
//
//  Created by Justin Zhang on 11/2/23.
//

import SwiftUI

enum GenderSelection: Int, CaseIterable {
    case male
    case female
    case custom
    case perferNot
    
    var title: String {
        switch self {
        case .male:
            return "Male"
        case .female:
            return "Female"
        case .custom:
            return "Custom"
        case .perferNot:
            return "Perfer Not To Say"
        }
    }
}
