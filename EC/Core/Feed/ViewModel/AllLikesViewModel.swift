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
        Task {
            try await fectchLikedUsers()
            try await grabUserPostsAndFollowingUser()
        }
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
    
    // grab user posts + following user
    @MainActor
    func grabUserPostsAndFollowingUser() async throws{
        if let allLikedUser = self.likedListUsers {
            for i in 0..<allLikedUser.count {
                let user = allLikedUser[i]
                let postCount = try await UserService().grabUserPosts(withUid: user.id)
                let followingUserCount = try await UserService().grabFollowingUser(withUid: user.id)
                self.likedListUsers?[i].posts = postCount
                self.likedListUsers?[i].followering = followingUserCount
            }
        }
    }
    
    func fetchUpdateGrabUserPostsAndFollowingUser() {
        if let allLikedUser = self.likedListUsers {
            for i in 0..<allLikedUser.count {
                let user = allLikedUser[i]
                UserService().fetchUpdateUserPosts(withUid: user.id) { postCount in
                    self.likedListUsers?[i].posts = postCount
                }
                UserService().fetchUpdateFollowingUser(withUid: user.id) { followingUserCount in
                    self.likedListUsers?[i].followering = followingUserCount
                }
            }
        }
    }
}
