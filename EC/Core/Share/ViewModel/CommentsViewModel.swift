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
    
    init(user: User, post: Post) {
        self.user = user
        self.post = post
    }
    
    func UploadComments(withPostId postId: String, caption: String) async throws {
        try await CommentService().uploadComment(postId: postId, caption: caption)
    }
}
