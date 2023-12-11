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
    
    func uploadCommentReply(commentId: String, caption: String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let commentsRepliesRef = Firestore.firestore().collection("comment-replies").document()
        let repliesRef = Firestore.firestore().collection("comments").document(commentId).collection("replies")
        
        let comment = Comment(id: commentsRepliesRef.documentID, caption: caption, likes: 0, comments: 0, timestamp: Timestamp(), ownerId: uid)
        guard let encodedComment = try? Firestore.Encoder().encode(comment) else {return}
        
        try await commentsRepliesRef.setData(encodedComment)
        try await repliesRef.document(commentsRepliesRef.documentID).setData([:])
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
    
    func fetchAllCommentReplies(commentId: String) async throws -> [Comment] {
        let snapshot = try await Firestore.firestore().collection("comments").document(commentId).collection("replies").getDocuments()
        let documents = snapshot.documents

        var allReplies = [Comment]()
        
        // update replies info
        for i in 0..<documents.count {
            let doc = documents[i]
            let replyId = doc.documentID
            
            let replySnapshot = try await Firestore.firestore().collection("comment-replies").document(replyId).getDocument()
            let reply = try replySnapshot.data(as: Comment.self)
            allReplies.append(reply)
        }
        
        // update user info
        for i in 0..<allReplies.count {
            let allDoc = allReplies[i]
            let userId = allDoc.ownerId
            
            let userSnapshot = try await Firestore.firestore().collection("users").document(userId).getDocument()
            let userData = try userSnapshot.data(as: User.self)
            allReplies[i].user = userData
        }
        
        return allReplies
    }
    
    func observeComments(withPostId postId: String, completion: @escaping(Comment) -> Void) {
        let collectionName = "post-comments"
        Firestore.firestore().collection("posts").document(postId).collection(collectionName).addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else { return }
            snapshot.documentChanges.forEach { documentChange in
                if documentChange.type == .added {
                    let docID = documentChange.document.documentID
                    Firestore.firestore().collection("comments").document(docID).getDocument { querySnapshot, _ in
                        guard let snapshot = querySnapshot else { return }
                        guard let comment = try? snapshot.data(as: Comment.self) else {return}
                        completion(comment)
                    }
                } else if documentChange.type == .removed {
                    let docID = documentChange.document.documentID
                    Firestore.firestore().collection("comments").document(docID).getDocument { querySnapshot, _ in
                        guard let snapshot = querySnapshot else { return }
                        guard let comment = try? snapshot.data(as: Comment.self) else {return}
                        completion(comment)
                    }
                }
            }
        }
    }
    
    func observeReplies(withCommentId commentId: String, completion: @escaping(Comment) -> Void) {
        let collectionName = "replies"
        Firestore.firestore().collection("comments").document(commentId).collection(collectionName).addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else { return }
            snapshot.documentChanges.forEach { documentChange in
                if documentChange.type == .added {
                    let docID = documentChange.document.documentID
                    Firestore.firestore().collection("comment-replies").document(docID).getDocument { querySnapshot, _ in
                        guard let snapshot = querySnapshot else { return }
                        guard let data = try? snapshot.data(as: Comment.self) else {return}
                        completion(data)
                    }
                } else if documentChange.type == .removed {
                    let docID = documentChange.document.documentID
                    Firestore.firestore().collection("comment-replies").document(docID).getDocument { querySnapshot, _ in
                        guard let snapshot = querySnapshot else { return }
                        guard let comment = try? snapshot.data(as: Comment.self) else {return}
                        completion(comment)
                    }
                }
            }
        }
    }
    
    // like comment
    func likeComment(withComment comment: Comment, completion: @escaping() -> Void) {
        let commentRef = Firestore.firestore().collection("comments").document(comment.id)
        commentRef.updateData(["likes": comment.likes + 1, "didLike": true]) { _ in
            completion()
        }
    }
    
    // like reply
    func likeReply(withReply reply: Comment, completion: @escaping() -> Void) {
        let replyRef = Firestore.firestore().collection("comment-replies").document(reply.id)
        replyRef.updateData(["likes": reply.likes + 1, "didLike": true]) { _ in
            completion()
        }
    }
    
    // unlike comment
    func unlikeComment(withComment comment: Comment, completion: @escaping() -> Void) {
        let commentRef = Firestore.firestore().collection("comments").document(comment.id)
        commentRef.updateData(["likes": comment.likes - 1, "didLike": false]) { _ in
            completion()
        }
    }
    
    // unlike reply
    func unlikeReply(withReply reply: Comment, completion: @escaping() -> Void) {
        let replyRef = Firestore.firestore().collection("comment-replies").document(reply.id)
        replyRef.updateData(["likes": reply.likes - 1, "didLike": false]) { _ in
            completion()
        }
    }
    
    // check for modify comments
    func observeCurrentComment(_ comment: Comment, completion: @escaping(Comment) -> Void) {
        Firestore.firestore().collection("comments").document(comment.id).addSnapshotListener { querySnapshot, error in
            guard let document = querySnapshot else {return}
            guard let data = try? document.data(as: Comment.self) else {return}
            completion(data)
        }
    }
    
    func observeCurrentReplies(withCommentId commentId: String, completion: @escaping(Comment) -> Void) {
        Firestore.firestore().collection("comment-replies").addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else { return }
            snapshot.documentChanges.forEach { documentChange in
                if documentChange.type == .modified {
                    guard let data = try? documentChange.document.data(as: Comment.self) else {return}
                    completion(data)
                }
            }
        }
    }
    
    func grabReplyAmount(_ comment: Comment, completion: @escaping(Int) -> Void) {
        Firestore.firestore().collection("comments").document(comment.id).collection("replies").getDocuments { querySnapshot, _ in
            guard let snapshot = querySnapshot else { return }
            completion(snapshot.count)
        }
    }
    
    func fetchUpdateGrapReplyAmount(comment: Comment, completion: @escaping(Int) -> Void) {
        Firestore.firestore().collection("comments").document(comment.id).collection("replies").addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else { return }
            completion(snapshot.count)
        }
    }
}
