//
//  UserService.swift
//  EC
//
//  Created by Justin Zhang on 11/2/23.
//

import SwiftUI
import Firebase

struct UserService {
    
    // fectch current user
    static func fetchUser(withUid uid: String) async throws -> User {
        let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
        return try snapshot.data(as: User.self)
    }
    
    // listener when user is updated
    static func observeUser(withUid uid: String, completion: @escaping(User) -> Void) {
        Firestore.firestore().collection("users").document(uid).addSnapshotListener { querySnapshot, error in
            guard let document = querySnapshot else {return}
            guard let data = try? document.data(as: User.self) else {return}
            completion(data)
        }
    }
    
    // fectch current user with completion handler
    static func fetchUserCompletion(withUid uid: String, completion: @escaping(User) -> Void) {
        Firestore.firestore().collection("users").document(uid).getDocument { querySnapshot, error in
            guard let document = querySnapshot else {return}
            guard let data = try? document.data(as: User.self) else {return}
            completion(data)
        }
    }
    
    // fetch posts
    static func fetchLikedUsers(likedList: [String]) async throws -> [User] {
        var users = [User]()
        for i in 0..<likedList.count {
            let likedUserId = likedList[i]
            let postUser = try await UserService.fetchUser(withUid: likedUserId)
            users.append(postUser)
        }
        return users
    }
    
    func followUser(followUserId otherUserId: String, completion: @escaping() -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let userFollowRef = Firestore.firestore().collection("users").document(uid).collection("user-follow")
        let followingUserRef = Firestore.firestore().collection("users").document(otherUserId).collection("following-user")
        
        userFollowRef.document(otherUserId).setData([:])
        followingUserRef.document(uid).setData([:])
        
        completion()
    }
    
    func unfollowUser(followUserId otherUserId: String, completion: @escaping() -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let userFollowRef = Firestore.firestore().collection("users").document(uid).collection("user-follow")
        let followingUserRef = Firestore.firestore().collection("users").document(otherUserId).collection("following-user")
        
        userFollowRef.document(otherUserId).delete()
        followingUserRef.document(uid).delete()
        
        completion()
    }
    
    // fectch user follow
    func fetchUserFollow(withUid uid: String) async throws -> [User] {
        let snapshot = try await Firestore.firestore().collection("users").document(uid).collection("user-follow").getDocuments()
        let documents = snapshot.documents
        
        var followers = [User]()
        
        for i in 0..<documents.count {
            let doc = documents[i]
            let userId = doc.documentID
            
            let userSnapshot = try await Firestore.firestore().collection("users").document(userId).getDocument()
            let follower = try userSnapshot.data(as: User.self)
            followers.append(follower)
        }
        
        return followers
    }
    
    // fectch following user
    func fetchFollowingUser(withUid uid: String) async throws -> [User] {
        let snapshot = try await Firestore.firestore().collection("users").document(uid).collection("following-user").getDocuments()
        let documents = snapshot.documents
        
        var allFollowing = [User]()
        
        for i in 0..<documents.count {
            let doc = documents[i]
            let userId = doc.documentID
            
            let userSnapshot = try await Firestore.firestore().collection("users").document(userId).getDocument()
            let following = try userSnapshot.data(as: User.self)
            allFollowing.append(following)
        }
        
        return allFollowing
    }
    
    // observe follower
    func observeFollowerOrFollowing(collectionName name: String, completion: @escaping(User) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Firestore.firestore().collection("users").document(uid).collection(name).addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else { return }
            
            snapshot.documentChanges.forEach { documentChange in
                if documentChange.type == .added {
                    let docID = documentChange.document.documentID
                    Firestore.firestore().collection("users").document(docID).getDocument { querySnapshot, _ in
                        guard let snapshot = querySnapshot else { return }
                        guard let user = try? snapshot.data(as: User.self) else {return}
                        completion(user)
                    }
                } else if documentChange.type == .removed {
                    let docID = documentChange.document.documentID
                    Firestore.firestore().collection("users").document(docID).getDocument { querySnapshot, _ in
                        guard let snapshot = querySnapshot else { return }
                        guard let user = try? snapshot.data(as: User.self) else {return}
                        completion(user)
                    }
                }
            }
        }
    }
    
    // grab posts
    func grabUserPosts(withUid uid: String) async throws -> Int{
        let snapshot = try await Firestore.firestore().collection("users").document(uid).collection("user-posts").getDocuments()
        return snapshot.count
    }
    
    // grab following user
    func grabFollowingUser(withUid uid: String) async throws -> Int{
        let snapshot = try await Firestore.firestore().collection("users").document(uid).collection("following-user").getDocuments()
        return snapshot.count
    }
    
    // grab user follow
    func grabUserFollow(withUid uid: String) async throws -> Int{
        let snapshot = try await Firestore.firestore().collection("users").document(uid).collection("user-follow").getDocuments()
        return snapshot.count
    }
    
    // grab user likes
    func grabUserLikes(withUid uid: String) async throws -> Int {
        let snapshot = try await Firestore.firestore().collection("users").document(uid).collection("user-likes").getDocuments()
        return snapshot.count
    }
    
    // observe user post
    func fetchUpdateUserPosts(withUid uid: String, completion: @escaping(Int) -> Void) {
        Firestore.firestore().collection("users").document(uid).collection("user-posts").addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else { return }
            completion(snapshot.count)
        }
    }
    
    // observe following user
    func fetchUpdateFollowingUser(withUid uid: String, completion: @escaping(Int) -> Void) {
        Firestore.firestore().collection("users").document(uid).collection("following-user").addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else { return }
            completion(snapshot.count)
        }
    }
    
    // observe user follow
    func fetchUpdateUserFollow(withUid uid: String, completion: @escaping(Int) -> Void){
        Firestore.firestore().collection("users").document(uid).collection("user-follow").addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else { return }
            completion(snapshot.count)
        }
    }
    
    // observe user likes
    func fetchUpdateUserLikes(withUid uid: String, completion: @escaping(Int) -> Void) {
        Firestore.firestore().collection("users").document(uid).collection("user-likes").addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else { return }
            completion(snapshot.count)
        }
    }
}
