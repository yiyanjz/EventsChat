//
//  PostService.swift
//  EC
//
//  Created by Justin Zhang on 11/8/23.
//

import SwiftUI
import Firebase

struct PostService {
    // fetch posts
    static func fetchPost() async throws -> [Post] {
        let snapshot = try await Firestore.firestore().collection("posts").getDocuments()
        var posts = try snapshot.documents.compactMap({ try $0.data(as: Post.self) })
        
        for i in 0..<posts.count {
            let post = posts[i]
            if let ownerId = post.ownerId {
                let postUser = try await UserService.fetchUser(withUid: ownerId)
                posts[i].user = postUser
            }
        }
        return posts
    }
    
    // observe posts
    static func observePostsAdd(completion: @escaping([Post]) -> Void) {
        Firestore.firestore().collection("posts").addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else { return }
            var pendingPost = [Post]()

            snapshot.documentChanges.forEach { documentChange in
                if documentChange.type == .added {
                    guard let data = try? documentChange.document.data(as: Post.self) else {return}
                    pendingPost.append(data)
                }
            }
            
            completion(pendingPost)
        }
    }
    
    // check for modify posts
    static func observePostsModify(completion: @escaping(Post) -> Void) {
        Firestore.firestore().collection("posts").addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else { return }

            snapshot.documentChanges.forEach { documentChange in
                if documentChange.type == .modified {
                    guard let data = try? documentChange.document.data(as: Post.self) else {return}
                    completion(data)
                }
            }
        }
    }
    
    // check for remove posts
    static func observePostsRemoved(completion: @escaping(Post) -> Void) {
        Firestore.firestore().collection("posts").addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else { return }

            snapshot.documentChanges.forEach { documentChange in
                if documentChange.type == .removed {
                    guard let data = try? documentChange.document.data(as: Post.self) else {return}
                    completion(data)
                }
            }
        }
    }
    
    // like post
    func likePost(_ post: Post, completion: @escaping() -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        let userLikeRef = Firestore.firestore().collection("users").document(uid).collection("user-likes")
        guard let userLiked = post.userLiked else {return}
        let newUserLiked = userLiked + [uid]
        
        Firestore.firestore().collection("posts").document(post.id).updateData(["likes": post.likes + 1, "userLiked": newUserLiked, "didLike": true]) { _ in
            userLikeRef.document(post.id).setData([:]) { _ in
                completion()
            }
        }
    }
    
    // unlike post
    func unlikePost(_ post: Post, completion: @escaping() -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        guard post.likes >= 0 else {return}
        
        let userLikeRef = Firestore.firestore().collection("users").document(uid).collection("user-likes")
        guard let userLiked = post.userLiked else {return}
        let newUserLiked = userLiked.filter({ $0 != uid })

        Firestore.firestore().collection("posts").document(post.id).updateData(["likes": post.likes - 1, "userLiked": newUserLiked, "didLike": false]) { _ in
            userLikeRef.document(post.id).delete() { _ in
                completion()
            }
        }
    }
    
    // star post
    func starPost(_ post: Post, completion: @escaping() -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        let userStarRef = Firestore.firestore().collection("users").document(uid).collection("user-stars")
        guard let userStar = post.userStared else {return}
        let newUserStared = userStar + [uid]
        
        Firestore.firestore().collection("posts").document(post.id).updateData(["stars": post.stars + 1, "userStared": newUserStared, "didStar": true]) { _ in
            userStarRef.document(post.id).setData([:]) { _ in
                completion()
            }
        }
    }
    
    // unstar post
    func unstarPost(_ post: Post, completion: @escaping() -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        guard post.stars >= 0 else {return}
        
        let userStarRef = Firestore.firestore().collection("users").document(uid).collection("user-stars")
        guard let userStar = post.userStared else {return}
        let newUserStared = userStar.filter({ $0 != uid })
        
        Firestore.firestore().collection("posts").document(post.id).updateData(["stars": post.stars - 1, "userStared": newUserStared, "didStar": false]) { _ in
            userStarRef.document(post.id).delete() { _ in
                completion()
            }
        }
    }
    
    // check for modify posts
    func observeCurrentPost(withPostID postID: String, completion: @escaping(Post) -> Void) {
        Firestore.firestore().collection("posts").document(postID).addSnapshotListener { querySnapshot, error in
            guard let document = querySnapshot else {return}
            guard let data = try? document.data(as: Post.self) else {return}
            completion(data)
        }
    }
    
    // filter likes / stars
    func fetchPostActionInfo(forUid uid:String, collectionName name: String) async throws -> [Post] {
        let snapshot = try await Firestore.firestore().collection("users").document(uid).collection(name).getDocuments()
        let documents = snapshot.documents
        
        var posts = [Post]()
        
        for i in 0..<documents.count {
            let doc = documents[i]
            let postId = doc.documentID
            
            let postSnapshot = try await Firestore.firestore().collection("posts").document(postId).getDocument()
            let post = try postSnapshot.data(as: Post.self)
            posts.append(post)
        }
        
        return posts
    }
    
    // check for liked posts / stars
    func observePostsActionInfo(forUid uid:String, collectionName name: String, completion: @escaping(Post) -> Void) {
        Firestore.firestore().collection("users").document(uid).collection(name).addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else { return }
            
            snapshot.documentChanges.forEach { documentChange in
                if documentChange.type == .added {
                    let docID = documentChange.document.documentID
                    Firestore.firestore().collection("posts").document(docID).getDocument { querySnapshot, _ in
                        guard let snapshot = querySnapshot else { return }
                        guard var post = try? snapshot.data(as: Post.self) else {return}
                        if let ownerId = post.ownerId {
                            UserService.fetchUserCompletion(withUid: ownerId) { postUser in
                                post.user = postUser
                                completion(post)
                            }
                        }
                    }
                } else if documentChange.type == .removed {
                    let docID = documentChange.document.documentID
                    Firestore.firestore().collection("posts").document(docID).getDocument { querySnapshot, _ in
                        guard let snapshot = querySnapshot else { return }
                        guard var post = try? snapshot.data(as: Post.self) else {return}
                        if let ownerId = post.ownerId {
                            UserService.fetchUserCompletion(withUid: ownerId) { postUser in
                                post.user = postUser
                                completion(post)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // fetch followers posts
    func fetchFollowerPosts() async throws -> [Post] {
        guard let uid = Auth.auth().currentUser?.uid else {return []}
        let userSnapshot = try await Firestore.firestore().collection("users").document(uid).collection("user-follow").getDocuments().documents
        
        var followersPost = [Post]()
        
        // add user followers posts
        if userSnapshot.count > 0 {
            for i in 0..<userSnapshot.count {
                let userId = userSnapshot[i].documentID
                let otherUserSnapshot = try await Firestore.firestore().collection("users").document(userId).collection("user-posts").getDocuments().documents
                if otherUserSnapshot.count > 0 {
                    for i in 0..<otherUserSnapshot.count {
                        let postId = otherUserSnapshot[i].documentID
                        let postSnapshot = try await Firestore.firestore().collection("posts").document(postId).getDocument()
                        let post = try postSnapshot.data(as: Post.self)
                        followersPost.append(post)
                    }
                }
            }
        }
        
        // add users posts
        let userPostSnapshot = try await Firestore.firestore().collection("users").document(uid).collection("user-posts").getDocuments().documents
        if userPostSnapshot.count > 0 {
            for i in 0..<userPostSnapshot.count {
                let postId = userPostSnapshot[i].documentID
                let postSnapshot = try await Firestore.firestore().collection("posts").document(postId).getDocument()
                let post = try postSnapshot.data(as: Post.self)
                followersPost.append(post)
            }
        }
        
        // add user
        for i in 0..<followersPost.count {
            let post = followersPost[i]
            if let ownerId = post.ownerId {
                let postUser = try await UserService.fetchUser(withUid: ownerId)
                followersPost[i].user = postUser
            }
        }
        
        return followersPost
    }
    
    // observe user follow
    func observeUserFollow(completion: @escaping(Post) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Firestore.firestore().collection("users").document(uid).collection("user-follow").addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else { return }
            snapshot.documentChanges.forEach { documentChange in
                if documentChange.type == .added {
                    let userId = documentChange.document.documentID
                    Firestore.firestore().collection("users").document(userId).collection("user-posts").getDocuments { snapshot, _ in
                        guard let otherUserDocuments = snapshot?.documents else {return}
                        otherUserDocuments.forEach { doc in
                            let postId = doc.documentID
                            Firestore.firestore().collection("posts").document(postId).getDocument { postSnapshot, _ in
                                guard let post = try? postSnapshot?.data(as: Post.self) else {return}
                                
                                completion(post)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // observe user unfollow
    func observeUserFollowRemoved(completion: @escaping(Post) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Firestore.firestore().collection("users").document(uid).collection("user-follow").addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else { return }
            snapshot.documentChanges.forEach { documentChange in
                if documentChange.type == .removed {
                    let userId = documentChange.document.documentID
                    Firestore.firestore().collection("users").document(userId).collection("user-posts").getDocuments { snapshot, _ in
                        guard let otherUserDocuments = snapshot?.documents else {return}
                        otherUserDocuments.forEach { doc in
                            let postId = doc.documentID
                            Firestore.firestore().collection("posts").document(postId).getDocument { postSnapshot, _ in
                                guard let post = try? postSnapshot?.data(as: Post.self) else {return}
                                
                                completion(post)
                            }
                        }
                    }
                }
            }
        }
    }
}
