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
    
    init(){
        Task { try await fetchPost() }
        observePostAdded()
        observePostRemoved()
    }
    
    @MainActor
    func fetchPost() async throws {
        self.posts = try await PostService.fetchPost()
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
                    }
                }
            }
        }
    }
    
    func observePostRemoved() {
        PostService.observePostsRemoved { post in
            self.posts = self.posts.filter({ $0.id != post.id})
        }
    }
}
