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
    
    func fetchAllPostComment(withPostId postId: String) async throws -> [Comment] {
        let snapshot = try await Firestore.firestore().collection("posts").document(postId).collection("post-comments").getDocuments()
        let documents = snapshot.documents
        
        var allPostComments = [Comment]()
        
        // update comment info
        for i in 0..<documents.count {
            let doc = documents[i]
            let commentId = doc.documentID
            
            let commentSnapshot = try await Firestore.firestore().collection("comments").document(commentId).getDocument()
            let comment = try commentSnapshot.data(as: Comment.self)
            allPostComments.append(comment)
        }
        
        // update user info
        for i in 0..<allPostComments.count {
            let allDoc = allPostComments[i]
            let userId = allDoc.ownerId
            
            let userSnapshot = try await Firestore.firestore().collection("users").document(userId).getDocument()
            let userData = try userSnapshot.data(as: User.self)
            allPostComments[i].user = userData
        }
        
        return allPostComments
    }
}
