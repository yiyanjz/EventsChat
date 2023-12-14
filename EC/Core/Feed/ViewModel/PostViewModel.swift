//
//  PostViewModel.swift
//  EC
//
//  Created by Justin Zhang on 11/14/23.
//

import SwiftUI
import Firebase

class PostViewModel: ObservableObject {
    private let service = PostService()
    @Published var post: Post
    @Published var currentUser: User?

    init(post: Post) {
        self.post = post
        fetchUpdatePost()
        Task { try await fetchCurrentUser() }
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
    
    // listener for user infor changes
    @MainActor
    func fetchCurrentUser() async throws {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        self.currentUser = try await UserService.fetchUser(withUid: uid)
    }
}
