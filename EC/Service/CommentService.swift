//
//  CommentService.swift
//  EC
//
//  Created by Justin Zhang on 12/9/23.
//

import SwiftUI
import Firebase

struct CommentService {
    func uploadComment(postId: String, caption: String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let commentsRef = Firestore.firestore().collection("comments").document()
        let postCommentRef = Firestore.firestore().collection("posts").document(postId).collection("post-comments")
        
        let comment = Comment(id: commentsRef.documentID, caption: caption, likes: 0, comments: 0, timestamp: Timestamp(), ownerId: uid, replies: [])
        guard let encodedComment = try? Firestore.Encoder().encode(comment) else {return}
        
        try await commentsRef.setData(encodedComment)
        try await postCommentRef.document(commentsRef.documentID).setData([:])
    }
}
