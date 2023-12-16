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
    @Published var showSharedView: Bool = false
    
    let service = PostService()

    init(user: User) {
        self.user = user
        observeUserFollow()
        fetchUpdateGrabUserPostsAndFollowingUser()
        Task {
            try await fetchFollowAndFollowing()
            try await grabUserPostsAndFollowingUser()
            try await fetchallUsersPosts(user: user)
        }
    }
    
    @MainActor
    // fetch all posts
    func fetchallUsersPosts(user: User) async throws {
        let posts = try await service.fetchPostActionInfo(forUid: user.id, collectionName: CollectionFilter.userPost.title)
        self.allPosts = posts
        
        if self.allPosts.count > 0 {
            for i in 0..<self.allPosts.count {
                self.allPosts[i].user = user
            }
        }
    }
    
    @MainActor
    // fetch all stared posts
    func fetchStaredPosts(user: User) async throws {
        let posts = try await service.fetchPostActionInfo(forUid: user.id, collectionName: CollectionFilter.userStared.title)
        self.staredPosts = posts
        
        if self.staredPosts.count > 0 {
            for i in 0..<self.staredPosts.count {
                let post = self.staredPosts[i]
                if let ownwerID = post.ownerId {
                    let postUser = try await UserService.fetchUser(withUid: ownwerID)
                    self.staredPosts[i].user = postUser
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
        let postCount = try await UserService().grabUserPosts(withUid: user.id)
        let followingUserCount = try await UserService().grabFollowingUser(withUid: user.id)
        let userFollow = try await UserService().grabUserFollow(withUid: user.id)
        let userLikes = try await UserService().grabUserLikes(withUid: user.id)
        user.posts = postCount
        user.followering = userFollow
        user.followers = followingUserCount
        user.likes = userLikes
    }
    
    func fetchUpdateGrabUserPostsAndFollowingUser() {
        UserService().fetchUpdateUserPosts(withUid: user.id) { postCount in
            self.user.posts = postCount
        }
        UserService().fetchUpdateFollowingUser(withUid: user.id) { userFollow in
            self.user.followers = userFollow
        }
        UserService().fetchUpdateUserFollow(withUid: user.id) { followingUserCount in
            self.user.followering = followingUserCount
        }
        UserService().fetchUpdateUserLikes(withUid: user.id) { userLikes in
            self.user.likes = userLikes
        }
    }
}
