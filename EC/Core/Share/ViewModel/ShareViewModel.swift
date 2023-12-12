//
//  ShareViewModel.swift
//  EC
//
//  Created by Justin Zhang on 12/7/23.
//

import SwiftUI
import Firebase

class ShareViewModel: ObservableObject {
    @Published var selectedUsers = [User]()
    @Published var searchUser: String = ""
    @Published var userFollowing = [User]()
    @Published var showShareNewGoup: Bool = false
    @Published var currentUser: User?
    
    init(){
        Task {
            try await getUserFollow()
            try await getCurrentUser()
        }
    }
        
    @MainActor
    func getUserFollow() async throws {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        self.userFollowing = try await UserService().fetchUserFollow(withUid: uid)
    }
    
    func deletePost(post: Post) async throws{
        try await CommentService().deletePost(post: post)
        try await CommentService().deleteUserActionInfo(post: post)
    }
    
    @MainActor
    func getCurrentUser() async throws {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        self.currentUser = try await UserService.fetchUser(withUid: uid)
    }
}
