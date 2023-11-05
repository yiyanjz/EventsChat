//
//  RegisterViewModel.swift
//  EC
//
//  Created by Justin Zhang on 11/2/23.
//

import SwiftUI

class RegisterViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var username = ""
    
    func createUser() async throws {
        try await AuthService.shared.createUser(email: email, password: password, username: username)
        await clearData()
    }
    
    @MainActor
    private func clearData() {
        email = ""
        username = ""
        password = ""
    }
}
