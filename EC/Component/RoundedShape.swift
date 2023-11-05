//
//  RoundedShape.swift
//  EC
//
//  Created by Justin Zhang on 11/2/23.
//

import SwiftUI

// Round corners
struct RoundedShape: Shape {
    var corners: UIRectCorner
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: 30, height: 30))
        return Path(path.cgPath)
    }
}
