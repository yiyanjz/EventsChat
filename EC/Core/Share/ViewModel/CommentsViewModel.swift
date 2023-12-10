//
//  CommentViewModel.swift
//  EC
//
//  Created by Justin Zhang on 12/9/23.
//

import SwiftUI

class CommentsViewModel: ObservableObject {
    @Published var comment: String = ""
    @Published var user: User
    @Published var post: Post
    @Published var allComments = [Comment]()
    
    init(user: User, post: Post) {
        self.user = user
        self.post = post
        Task { try await fetchAllPostComment(withPostId:post.id) }
    }
    
    func UploadComments(withPostId postId: String, caption: String) async throws {
        try await CommentService().uploadComment(postId: postId, caption: caption)
    }
    
    @MainActor
    func fetchAllPostComment(withPostId postId: String) async throws {
        self.allComments = try await CommentService().fetchAllPostComment(withPostId: postId)
    }
}
