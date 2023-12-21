//
//  FeedViewModel.swift
//  EC
//
//  Created by Justin Zhang on 11/8/23.
//

import SwiftUI
import Firebase

class FeedViewModel: ObservableObject {
    @Published var posts = [Post]()
    @Published var showSearchView: Bool = false
    @Published var showPostDetail: Bool = false
    @Published var selectedPost: Post?
    @Published var followersPosts = [Post]()
    @Published var currentUser: User?
    
    init(){
        Task {
            try await fetchPost()
            try await fetchFollowerPosts()
            try await getCurrentUser()
        }
        observePostAdded()
        observePostRemoved()
        observeUserFollow()
        observeUserFollowRemoved()
    }
    
    @MainActor
    func getCurrentUser() async throws {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        self.currentUser = try await UserService.fetchUser(withUid: uid)
    }
    
    @MainActor
    func fetchPost() async throws {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        self.posts = try await PostService.fetchPost(withUserId: uid)
    }
    
    // listener for user infor changes
    func observePostAdded() {
        PostService.observePostsAdd() { [weak self] posts in
            posts.forEach { post in
                var post = post
                if let ownerId = post.ownerId {
                    UserService.fetchUserCompletion(withUid: ownerId) { user in
                        post.user = user
                        self?.posts.insert(post, at: 0)
                        self?.followersPosts.insert(post, at: 0)
                    }
                }
            }
        }
    }
    
    func observePostRemoved() {
        PostService.observePostsRemoved { post in
            self.posts = self.posts.filter({ $0.id != post.id})
            self.followersPosts = self.followersPosts.filter({ $0.id != post.id})
        }
    }
    
    @MainActor
    func fetchFollowerPosts() async throws {
        self.followersPosts = try await PostService().fetchFollowerPosts()
    }
    
    // observe user follow
    func observeUserFollow() {
        PostService().observeUserFollow { post in
            if let ownerId = post.ownerId {
                UserService.fetchUserCompletion(withUid: ownerId) { postUser in
                    var newPost = post
                    newPost.user = postUser
                    self.followersPosts.append(newPost)
                }
            }
        }
    }
    
    // observe user unfollow
    func observeUserFollowRemoved() {
        PostService().observeUserFollowRemoved { post in
            self.followersPosts = self.followersPosts.filter({ $0.id != post.id})
        }
    }
}
