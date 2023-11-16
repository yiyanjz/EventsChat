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
}
