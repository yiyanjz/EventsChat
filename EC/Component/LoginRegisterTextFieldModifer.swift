//
//  LoginRegisterTextFieldModifer.swift
//  EC
//
//  Created by Justin Zhang on 11/2/23.
//

import SwiftUI

struct LoginRegisterTextFieldModifer: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.subheadline)
            .padding(12)
            .background(Color(uiColor: .systemGray4))
            .cornerRadius(10)
            .padding(.horizontal, 25)
    }
}
