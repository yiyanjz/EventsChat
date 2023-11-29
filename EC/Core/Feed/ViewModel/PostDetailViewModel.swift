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
    
    init(post: Post) {
        self.post = post
        checkIfUserLikedPost()
        checkIfUserStarPost()
        fetchUpdatePost()
        Task { try await fetchCurrentUser() }
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
}
