//
//  ProfileViewModel.swift
//  EC
//
//  Created by Justin Zhang on 11/2/23.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift
import Combine


class ProfileViewModel: ObservableObject {
    @Published var user: User
        
    init(user: User) {
        self.user = user
        fetchCurrentUser()
    }
    
    // listener for user infor changes
    func fetchCurrentUser() {
        UserService.observeUser(withUid: user.id) { user in
            self.user = user
        }
    }
}
