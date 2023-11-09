//
//  CircularProfileImageView.swift
//  EC
//
//  Created by Justin Zhang on 11/2/23.
//

import Kingfisher
import SwiftUI

// give the image different sizes
enum ProfileImageSize {
    case xxxsmall
    case xxsmall
    case xsmall
    case small
    case medium
    case large
    
    var dimension: CGFloat {
        switch self {
        case .xxxsmall:
            return 20
        case .xxsmall:
            return 30
        case .xsmall:
            return 40
        case .small:
            return 48
        case .medium:
            return 64
        case .large:
            return 80
        }
    }
}

struct CircularProfileImageView: View {
    let user: User
    let size: ProfileImageSize
    
    var body: some View {
        if let imageUrl = user.profileImageUrl {
            KFImage(URL(string: imageUrl))
                .resizable()
                .scaledToFill()
                .frame(width: size.dimension, height: size.dimension)
                .clipShape(Circle())
        } else {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: size.dimension, height: size.dimension)
                .clipShape(Circle())
                .foregroundColor(Color(.systemGray4))
        }
    }
}
