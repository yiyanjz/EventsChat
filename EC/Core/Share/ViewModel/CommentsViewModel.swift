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
    @Published var replies: Bool = false
    @Published var replyTo: String = "Say Something"
    @Published var replyComment: Comment?
    
    init(user: User, post: Post) {
        self.user = user
        self.post = post
        Task { try await fetchAllPostComment(withPostId:post.id) }
        DispatchQueue.main.async {
            self.observeComments(withPostId: post.id)
        }
    }
    
    func UploadComments(withPostId postId: String, caption: String) async throws {
        try await CommentService().uploadComment(postId: postId, caption: caption)
    }
    
    @MainActor
    func fetchAllPostComment(withPostId postId: String) async throws {
        self.allComments = try await CommentService().fetchAllPostComment(withPostId: postId)
    }
    
    func observeComments(withPostId postId: String) {
        CommentService().observeComments(withPostId: postId) { comment in
            let ownerId = comment.ownerId
            UserService.fetchUserCompletion(withUid: ownerId) { user in
                var newComment = comment
                newComment.user = user
                self.allComments.insert(newComment, at: 0)
            }
        }
    }
    
    // upload replies
    func uploadReplies(withComment comment: Comment, caption: String) async throws {
        try await CommentService().uploadCommentReply(commentId: comment.id, caption: caption)
    }
}
