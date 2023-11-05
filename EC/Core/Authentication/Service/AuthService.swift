//
//  AuthService.swift
//  EC
//
//  Created by Justin Zhang on 11/2/23.
//

import FirebaseAuth
import FirebaseFirestoreSwift
import Firebase

class AuthService {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    static let shared = AuthService()
    
    init() {
        Task { try await loadUserData()  }
    }
    
    @MainActor
    func loadUserData() async throws {
        self.userSession = Auth.auth().currentUser
        guard let currentUid = userSession?.uid else {return}
        self.currentUser = try await UserService.fetchUser(withUid: currentUid)
    }
}

// MARK - Register Users
@MainActor
extension AuthService {
    func createUser(email: String, password: String, username: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            try await uploadUserData(uid: result.user.uid, username: username, email: email)
        } catch {
            print("AuthService: Failed to register user: \(error.localizedDescription)")
        }
    }
    
    private func uploadUserData(uid: String, username: String, email: String) async throws {
        do {
            let user = User(id: uid, email: email, username: username)
            self.currentUser = user
            guard let encodedUser = try? Firestore.Encoder().encode(user) else {return}
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
        } catch {
            print("AuthService: Failed to upload user data: \(error.localizedDescription)")
        }
    }
}

// MARK - Login Users
@MainActor
extension AuthService {
    func login(withEmail email:String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            // to fectch user after log out
            try await loadUserData()
        } catch {
            print("AuthService: Failed to login User: \(error.localizedDescription)")
        }
    }
}

// MARK - Signout
extension AuthService {
    func signout() {
        try? Auth.auth().signOut()
        self.userSession = nil
    }
}

