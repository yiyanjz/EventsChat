//
//  CommentCellViewModel.swift
//  EC
//
//  Created by Justin Zhang on 12/9/23.
//

import SwiftUI

class CommentCellViewModel: ObservableObject {
    @Published var comment: Comment
    @Published var showMoreReplies: Bool = false
    @Published var replyCount: Int = 0
    @Published var showCommentInfo: Bool = false
    @Published var showReplyInfo: Bool = false
    @Published var post: Post
    @Published var selectedReply: Comment?
    
    init(comment: Comment, post: Post) {
        self.comment = comment
        self.post = post
        fetchUpdateComment(comment: comment)
        fetchUpdateCommnetReplies(comment: comment)
        grabReplyAmount(comment: comment)
        fetchUpdateGrapReplyAmount(comment: comment)
        observeRepliesRemove(withCommentId: comment.id)
        Task { try await fetchReplies(comment: comment)}
        DispatchQueue.main.async {
            self.observeReplies(withCommentId: comment.id)
        }
    }
    
    // like comment
    func likeComment(comment: Comment){
        CommentService().likeComment(withComment: comment) {}
    }
    
    // unlike comment
    func unlikeComment(comment: Comment){
        CommentService().unlikeComment(withComment: comment) {}
    }
    
    // listener for modified changes
    func fetchUpdateComment(comment: Comment){
        CommentService().observeCurrentComment(comment) { comment in
            let temp_user = self.comment.user
            let temp_replies = self.comment.replies
            self.comment = comment
            self.comment.user = temp_user
            self.comment.replies = temp_replies
        }
    }
    
    @MainActor
    func fetchReplies(comment: Comment) async throws {
        self.comment.replies = try await CommentService().fetchAllCommentReplies(commentId: comment.id)
    }
    
    func observeReplies(withCommentId commentId: String){
        CommentService().observeReplies(withCommentId: commentId) { comment in
            let ownerId = comment.ownerId
            UserService.fetchUserCompletion(withUid: ownerId) { user in
                var newComment = comment
                newComment.user = user
                self.comment.replies?.insert(newComment, at: 0)
            }
        }
    }
    
    func observeRepliesRemove(withCommentId commentId: String) {
        CommentService().observeRepliesRemove(withCommentId: commentId) { comment in
            self.comment.replies = self.comment.replies?.filter({ $0.id != comment.id})
        }
    }
    
    // like reply
    func likeReply(reply: Comment){
        CommentService().likeReply(withReply: reply) {}
    }
    
    // unlike reply
    func unlikeReply(reply: Comment){
        CommentService().unlikeReply(withReply: reply) {}
    }
    
    func fetchUpdateCommnetReplies(comment: Comment) {
        CommentService().observeCurrentReplies(withCommentId: comment.id) { comment in
            guard let replies = self.comment.replies else {return}
            for i in 0..<replies.count {
                let reply = replies[i]
                if reply.id == comment.id {
                    let temp_user = self.comment.replies?[i].user
                    self.comment.replies?[i] = comment
                    self.comment.replies?[i].user = temp_user
                }
            }
        }
    }
    
    // grab count
    func grabReplyAmount(comment: Comment) {
        CommentService().grabReplyAmount(comment) { count in
            self.replyCount = count
        }
    }
    
    func fetchUpdateGrapReplyAmount(comment: Comment) {
        CommentService().fetchUpdateGrapReplyAmount(comment: comment) { count in
            self.replyCount = count
        }
    }
    
    // delete comment
    func deleteComment(comment: Comment, post: Post) async throws {
        try await CommentService().deleteComment(comment: comment, post: post)
    }
    
    // delete replies
    func deleteReply(comment: Comment, reply: Comment) async throws {
        try await CommentService().deleteReply(comment: comment, reply: reply)
    }
}
