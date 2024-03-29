//
//  ShareNewGroupViewModel.swift
//  EC
//
//  Created by Justin Zhang on 12/9/23.
//

import SwiftUI
import Firebase

class ShareNewGroupViewModel: ObservableObject {
    @Published var groupName: String = ""
    @Published var searchUser: String = ""
    @Published var userFollowing = [User]()
    @Published var shareTo = [User]()
    
    init(){
        Task {
            try await getUserFollow()
        }
    }
    
    @MainActor
    func getUserFollow() async throws {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        self.userFollowing = try await UserService().fetchUserFollow(withUid: uid)
    }
}
