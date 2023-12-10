//
//  SearchService.swift
//  EC
//
//  Created by Justin Zhang on 11/16/23.
//

import SwiftUI
import Firebase

struct SearchService {
    // upload search
    func uploadSearch(allSearchText: [String]) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        // path ref
        let searchAllRef = Firestore.firestore().collection("search").document(uid)
        
        // refactor data
        let search = Search(id: UUID().uuidString, content: allSearchText)
        guard let encodedSearch = try? Firestore.Encoder().encode(search) else {return}
        
        // set data for user search results and all search results
        try await searchAllRef.setData(encodedSearch)
    }
    
    // update search
    func updateSearch(allSearchText: [String]) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let userSearchRef = Firestore.firestore().collection("search").document(uid)
        
        try await userSearchRef.updateData(["content": allSearchText])
    }
    
    // found search
    func foundSearch(allSearchText: [String], idx: Int) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let userSearchRef = Firestore.firestore().collection("search").document(uid)
        
        var allSearchText = allSearchText
        let element = allSearchText.remove(at: idx)
        allSearchText.insert(element, at: 0)

        try await userSearchRef.updateData(["content": allSearchText])
    }
    
    // fetch all user search
    func fetchUserSearch(withUid uid: String) async throws -> Search {
        let snapshot = try await Firestore.firestore().collection("search").document(uid).getDocument()
        return try snapshot.data(as: Search.self)
    }
    
    // observe fectch listern
    func observeUserSearch(withUid uid: String, completion: @escaping(Search) -> Void) {
        Firestore.firestore().collection("search").document(uid).addSnapshotListener { querySnapshot, error in
            guard let document = querySnapshot else {return}
            guard let data = try? document.data(as: Search.self) else {return}
            completion(data)
        }
    }
    
    // delete history
    func deleteHistory(withUid uid: String) async throws {
        try await Firestore.firestore().collection("search").document(uid).delete()
    }
    
    // search filter results (need to add tag + location)
    func searchFilterResults(searchText: String) async throws -> [Post] {
        let snapshot = try await Firestore.firestore().collection("posts").getDocuments()
        var posts = try snapshot.documents.compactMap({ try $0.data(as: Post.self) })
        
        var resultPost = [Post]()
        
        for i in 0..<posts.count {
            let post = posts[i]
            let searchTerm = post.title + post.caption
            if searchTerm.contains(searchText) {
                if let ownerId = post.ownerId {
                    let postUser = try await UserService.fetchUser(withUid: ownerId)
                    posts[i].user = postUser
                    resultPost.append(posts[i])
                }
            }
        }
        
        return resultPost
    }
    
    // search filter results (used user.username + user.fullname + user.email + user.bio)
    func searchFilterUserResults(searchText: String) async throws -> [User] {
        let snapshot = try await Firestore.firestore().collection("users").getDocuments()
        let users = try snapshot.documents.compactMap({ try $0.data(as: User.self) })

        var resultPost = [User]()
        
        for i in 0..<users.count {
            let user = users[i]
            let searchTerm = user.username + (user.fullname ?? "") + user.email + (user.bio ?? "")
            if searchTerm.contains(searchText) {
                resultPost.append(user)
            }
        }
        
        return resultPost
    }
}
