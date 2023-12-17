//
//  MentionViewModel.swift
//  EC
//
//  Created by Justin Zhang on 12/17/23.
//

import SwiftUI
import Firebase

class MentionViewModel: ObservableObject {
    @Published var searchName: String = ""
    @Published var usersName = ["Hannah", "Justin", "Jun", "Liqi"]
    @Published var currentUser: User?
    @Published var userFollow = [User]()
    @Binding var selectedMentionUser: [User]
    @Published var selectedUser = [User]()
    
    init(selectedMentionUser: Binding<[User]>) {
        self._selectedMentionUser = selectedMentionUser
        Task {
            try await getCurrentUser()
            try await fetchFollowAndFollowing()
        }
    }
    
    @MainActor
    func getCurrentUser() async throws {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        self.currentUser = try await UserService.fetchUser(withUid: uid)
    }
    
    @MainActor
    func fetchFollowAndFollowing() async throws {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        self.userFollow = try await UserService().fetchUserFollow(withUid: uid)
    }
}
