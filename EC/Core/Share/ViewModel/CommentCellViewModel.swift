//
//  CommentCellViewModel.swift
//  EC
//
//  Created by Justin Zhang on 12/9/23.
//

import SwiftUI

class CommentCellViewModel: ObservableObject {
    @Published var comment: Comment
    
    init(comment: Comment) {
        self.comment = comment
        checkIfUserLikedComment(comment: comment)
        fetchUpdateComment(comment: comment)
    }
    
    // like post
    func likeComment(comment: Comment){
        CommentService().likeComment(withComment: comment) {}
    }
    
    // unlike post
    func unlikeComment(comment: Comment){
        CommentService().unlikeComment(withComment: comment) {}
    }
    
    // check for prefilled likes
    func checkIfUserLikedComment(comment: Comment) {
        CommentService().checkIfUserLikedComment(comment) { didLike in
            if didLike {
                self.comment.didLike = true
            }
        }
    }
    
    // listener for modified changes
    func fetchUpdateComment(comment: Comment){
        CommentService().observeCurrentComment(comment) { comment in
            let temp_user = self.comment.user
            self.comment = comment
            self.comment.user = temp_user
        }
    }
}
