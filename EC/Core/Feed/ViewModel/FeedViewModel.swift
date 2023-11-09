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
    
    init(){
        Task { try await fetchPost() }
        fetchCurrentPost()
    }
    
    @MainActor
    func fetchPost() async throws {
        self.posts = try await PostService.fetchPost()
    }
    
    // listener for user infor changes
    func fetchCurrentPost() {
        PostService.observePost() { [weak self] posts in
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
}
