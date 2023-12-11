//
//  PostDetailViewModel.swift
//  EC
//
//  Created by Justin Zhang on 11/15/23.
//

import SwiftUI
import Firebase

class PostDetailViewModel: ObservableObject {
    @Published var comment = ""
    @Published var post: Post
    private let service = PostService()
    @Published var showShared: Bool = false
    @Published var showUserProfile: Bool = false
    @Published var currentUser: User?
    @Published var userFollow = [User]()
    
    init(post: Post) {
        self.post = post
        checkIfUserLikedPost()
        checkIfUserStarPost()
        fetchUpdatePost()
        observeUserFollow()
        Task {
            try await fetchCurrentUser()
            try await fetchFollowAndFollowing()
        }
    }
    
    // listener for user infor changes
    @MainActor
    func fetchCurrentUser() async throws {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        self.currentUser = try await UserService.fetchUser(withUid: uid)
    }
    
    // like post
    func likePost(){
        service.likePost(post){}
    }
    
    // unlike post
    func unlikePost(){
        service.unlikePost(post){}
    }
    
    // check for prefilled likes
    func checkIfUserLikedPost() {
        service.checkIfUserLikedPost(post) { didLike in
            if didLike {
                self.post.didLike = true
            }
        }
    }
    
    // listener for modified changes
    func fetchUpdatePost(){
        service.observeCurrentPost(withPostID: post.id) { post in
            let temp_user = self.post.user
            self.post = post
            self.post.user = temp_user
        }
    }
    
    // star post
    func starPost() {
        service.starPost(post){}
    }
    
    // unstar post
    func unstarPost() {
        service.unstarPost(post) {}
    }
    
    // check for prefilled stars
    func checkIfUserStarPost() {
        service.checkIfUserStaredPost(post) { didStar in
            if didStar {
                self.post.didStar = true
            }
        }
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
