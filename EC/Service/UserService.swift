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
    
    static func fetchUserCompletion(withUid uid: String, completion: @escaping(User) -> Void) {
        Firestore.firestore().collection("users").document(uid).getDocument { querySnapshot, error in
            guard let document = querySnapshot else {return}
            guard let data = try? document.data(as: User.self) else {return}
            completion(data)
        }
    }
}
