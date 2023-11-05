//
//  SettingFilter.swift
//  EC
//
//  Created by Justin Zhang on 11/2/23.
//

import SwiftUI

enum SettingFilter: Int, CaseIterable, Identifiable {
    case darkMode
    case activeStatus
    case accessibility
    case privacy
    case notifications
    
    var id: Int { return self.rawValue }
    
    var title: String {
        switch self {
        case .darkMode:
            return "Dark Mode"
        case .activeStatus:
            return "Active Status"
        case .accessibility:
            return "Accessibility"
        case .privacy:
            return "Privacy"
        case .notifications:
            return "Notifications"
        }
    }
    
    var imageName: String {
        switch self {
        case .darkMode:
            return "moon.circle.fill"
        case .activeStatus:
            return "message.badge.circle.fill"
        case .accessibility:
            return "person.circle.fill"
        case .privacy:
            return "lock.circle.fill"
        case .notifications:
            return "bell.circle.fill"
        }
    }
    
    var imageBackgroundColor: Color {
        switch self {
        case .darkMode:
            return Color(.black)
        case .activeStatus:
            return Color(.systemGreen)
        case .accessibility:
            return Color(.black)
        case .privacy:
            return Color(.systemBlue)
        case .notifications:
            return Color(.systemPurple)
        }
    }
}
