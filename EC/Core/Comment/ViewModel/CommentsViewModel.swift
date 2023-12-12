//
//  CommentViewModel.swift
//  EC
//
//  Created by Justin Zhang on 12/9/23.
//

import SwiftUI
import Firebase

class CommentsViewModel: ObservableObject {
    @Published var comment: String = ""
    @Published var user: User
    @Published var post: Post
    @Published var allComments = [Comment]()
    @Published var replies: Bool = false
    @Published var replyTo: String = "Say Something"
    @Published var replyComment: Comment?
    @Published var currentUser: User?
    
    init(user: User, post: Post) {
        self.user = user
        self.post = post
        Task {
            try await fetchAllPostComment(withPostId:post.id)
            try await grabCurrentUser()
        }
        DispatchQueue.main.async {
            self.observeComments(withPostId: post.id)
            self.observeCommentsRemoved(withPostId: post.id)
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
    
    func observeCommentsRemoved(withPostId postId: String) {
        CommentService().observeCommentsRemoved(withPostId: postId) { comment in
            self.allComments = self.allComments.filter({ $0.id != comment.id})
        }
    }
    
    // upload replies
    func uploadReplies(withComment comment: Comment, caption: String) async throws {
        try await CommentService().uploadCommentReply(commentId: comment.id, caption: caption)
    }
    
    @MainActor
    func grabCurrentUser() async throws {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        self.currentUser = try await UserService.fetchUser(withUid: uid)
    }
}
