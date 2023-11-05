//
//  LoginButtonModifer.swift
//  EC
//
//  Created by Justin Zhang on 11/2/23.
//

import SwiftUI

struct LoginButtonModifer: ViewModifier {
    let color: Color
    
    func body(content: Content) -> some View {
        content
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(width: 320, height: 44)
            .background(color)
            .cornerRadius(8)
    }
}
