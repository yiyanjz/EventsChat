//
//  LoginViewModel.swift
//  EC
//
//  Created by Justin Zhang on 11/2/23.
//

import SwiftUI

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    
    func logIn() async throws{
        try await AuthService.shared.login(withEmail: email, password: password)
    }
}
