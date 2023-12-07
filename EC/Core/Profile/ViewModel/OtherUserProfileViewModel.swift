//
//  OtherUserProfileViewModel.swift
//  EC
//
//  Created by Justin Zhang on 11/28/23.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift
import Combine


class OtherUserProfileViewModel: ObservableObject {
    @Published var user: User
    @Published var allPosts = [Post]()
    @Published var staredPosts = [Post]()
    @Published var showPostDetails: Bool = false
    @Published var selectedPost: Post?
    @Published var userFollow = [User]()
    @Published var followingUser = [User]()
    
    let service = PostService()

    init(user: User) {
        self.user = user
        fetchallUsersPosts()
        fetchallUserStars()
        observeUserFollow()
        observeFollowingUser()
        Task {
            try await fetchFollowAndFollowing()
        }
    }
    
    func fetchallUsersPosts() {
        service.fetchPostActionInfo(forUid: user.id, collectionName: CollectionFilter.userPost.title) { [self] posts in
            self.allPosts = posts
            
            for i in 0..<posts.count {
                self.allPosts[i].user = self.user
            }
        }
    }
    
    func fetchallUserStars() {
        service.fetchPostActionInfo(forUid: user.id, collectionName: CollectionFilter.userStared.title) { [self] posts in
            self.staredPosts = posts
            
            for i in 0..<posts.count {
                let post = posts[i]
                if let ownerId = post.ownerId {
                    UserService.fetchUserCompletion(withUid: ownerId) { postUser in
                        self.staredPosts[i].user = postUser
                    }
                }
            }
        }
    }
    
    func followUser(followUserId otherUserId: String) {
        UserService().followUser(followUserId: otherUserId) {
        }
    }
    
    func unfollowUser(followUserId otherUserId: String) {
        UserService().unfollowUser(followUserId: otherUserId) {
        }
    }
    
    @MainActor
    func fetchFollowAndFollowing() async throws {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        self.userFollow = try await UserService().fetchUserFollow(withUid: uid)
        self.followingUser = try await UserService().fetchFollowingUser(withUid: uid)
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
    
    func observeFollowingUser() {
        UserService().observeFollowerOrFollowing(collectionName: "following-user") { user in
            if self.followingUser.contains(user) {
                self.followingUser = self.followingUser.filter({ $0 != user})
            }else {
                self.followingUser.append(user)
            }
        }
    }
}
