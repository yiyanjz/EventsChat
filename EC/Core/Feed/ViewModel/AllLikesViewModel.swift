//
//  AllLikesViewModel.swift
//  EC
//
//  Created by Justin Zhang on 11/14/23.
//

import SwiftUI

class AllLikesViewModel: ObservableObject {
    @Published var likedList: [String]
    @Published var likedListUsers: [User]?
    
    init(likedList: [String]) {
        self.likedList = likedList
        Task { try await fectchLikedUsers() }
    }
    
    @MainActor
    func fectchLikedUsers() async throws {
        self.likedListUsers = try await UserService.fetchLikedUsers(likedList: likedList)
    }
}
