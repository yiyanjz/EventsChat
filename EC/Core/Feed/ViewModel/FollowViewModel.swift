//
//  FollowViewModel.swift
//  EC
//
//  Created by Justin Zhang on 11/13/23.
//

import SwiftUI
import Firebase

class FollowViewModel: ObservableObject {
    private let service = PostService()
    @Published var post: Post
    @Published var showAllLikes: Bool = false
    @Published var showComments: Bool = false
    @Published var showShared: Bool = false
    @Published var currentUser: User?
    
    init(post: Post) {
        self.post = post
        fetchUpdatePost()
        Task { try await grabCurrentUser() }
    }
    
    // like post
    func likePost(){
        service.likePost(post){}
    }
    
    // unlike post
    func unlikePost(){
        service.unlikePost(post){}
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
    
    @MainActor
    func grabCurrentUser() async throws {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        self.currentUser = try await UserService.fetchUser(withUid: uid)
    }
}
