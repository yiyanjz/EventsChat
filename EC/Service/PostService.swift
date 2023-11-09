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
    static func observePost(completion: @escaping([Post]) -> Void) {
        Firestore.firestore().collection("posts").addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else { return }
            var pendingPost = [Post]()

            snapshot.documentChanges.forEach { documentChange in
                switch documentChange.type {
                case .added:
                    guard let data = try? documentChange.document.data(as: Post.self) else {return}
                    pendingPost.append(data)
                case .modified:
                    print("Pending User Modified")
                case .removed:
                    print("User pending removed")
                }
            }
            
            completion(pendingPost)
        }
    }
}
