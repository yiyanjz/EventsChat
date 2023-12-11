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
    
    init(comment: Comment) {
        self.comment = comment
        fetchUpdateComment(comment: comment)
        fetchUpdateCommnetReplies(comment: comment)
        grabReplyAmount(comment: comment)
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
}
