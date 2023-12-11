//
//  AllLikesViewModel.swift
//  EC
//
//  Created by Justin Zhang on 11/14/23.
//

import SwiftUI
import Firebase

class AllLikesViewModel: ObservableObject {
    @Published var likedList: [String]
    @Published var likedListUsers: [User]?
    @Published var userFollow = [User]()
    
    init(likedList: [String]) {
        self.likedList = likedList
        observeUserFollow()
        Task { try await fectchLikedUsers() }
    }
    
    @MainActor
    func fectchLikedUsers() async throws {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let grabLikeListUsers = try await UserService.fetchLikedUsers(likedList: likedList)
        self.likedListUsers = grabLikeListUsers.filter({ $0.id != uid})
    }
    
    // follow user
    func followUser(followUserId otherUserId: String) {
        UserService().followUser(followUserId: otherUserId) {
        }
    }
    
    // unfollow user
    func unfollowUser(followUserId otherUserId: String) {
        UserService().unfollowUser(followUserId: otherUserId) {
        }
    }
    
    @MainActor
    func fetchFollowAndFollowing() async throws {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        self.userFollow = try await UserService().fetchUserFollow(withUid: uid)
    }
    
    func observeUserFollow() {
        UserService().observeFollowerOrFollowing(collectionName: "user-follow") { user in
            if self.userFollow.contains(user) {
                self.userFollow = self.userFollow.filter({ $0 != user})
            }else {
                self.userFollow.append(user)
            }
        }
    }
}
