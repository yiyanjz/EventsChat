//
//  SearchResultViewModel.swift
//  EC
//
//  Created by Justin Zhang on 11/19/23.
//

import SwiftUI
import Firebase

class SearchResultViewModel: ObservableObject {
    @Published var postsResult = [Post]()
    @Binding var searchText: String
    @Binding var searched: Bool
    @Published var showPostDetail: Bool = false
    @Published var selectedPost: Post?
    @Published var usersResult = [User]()
    @Published var userFollow = [User]()
    @Published var followingUser = [User]()
    
    let service = SearchService()
    
    init(searchText:Binding<String>, searched: Binding<Bool>) {
        self._searchText = searchText
        self._searched = searched
        Task {
            try await searchFilterResults()
            try await searchFilterUserResults()
            try await fetchFollowAndFollowing()
        }
        observeUserFollow()
        observeFollowingUser()
    }
    
    // search and filter posts with search tag / title / capation
    // stores in a array of post
    @MainActor
    func searchFilterResults() async throws {
        self.postsResult = try await service.searchFilterResults(searchText: searchText)
    }
    
    @MainActor
    func searchFilterUserResults() async throws {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        var userResult = try await service.searchFilterUserResults(searchText: searchText)
        self.usersResult = userResult.filter({$0.id != uid})
    }
    
    func followUser(followUserId otherUserId: String) {
        UserService().followUser(followUserId: otherUserId) {
        }
    }
    
    func unfollowUser(followUserId otherUserId: String) {
        UserService().unfollowUser(followUserId: otherUserId) {
        }
    }
    
    @MainActor
    func fetchFollowAndFollowing() async throws {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        self.userFollow = try await UserService().fetchUserFollow(withUid: uid)
        self.followingUser = try await UserService().fetchFollowingUser(withUid: uid)
    }
    
    func observeUserFollow() {
        UserService().observeFollowerOrFollowing(collectionName: "user-follow") { user in
            if self.userFollow.contains(user) {
                self.userFollow = self.userFollow.filter({ $0 != user})
            }else {
                self.userFollow.append(user)
            }
        }
    }
    
    func observeFollowingUser() {
        UserService().observeFollowerOrFollowing(collectionName: "following-user") { user in
            if self.followingUser.contains(user) {
                self.followingUser = self.followingUser.filter({ $0 != user})
            }else {
                self.followingUser.append(user)
            }
        }
    }
}
