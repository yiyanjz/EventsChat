//
//  ProfileInfoViewModel.swift
//  EC
//
//  Created by Justin Zhang on 12/11/23.
//

import SwiftUI
import Firebase


class ProfileInfoViewModel: ObservableObject {
    @Published var user: User
    @Published var searchFollowing: String = ""
    @Published var searchFollow: String = ""
    @Published var userFollow = [User]()
    @Published var followingUser = [User]()
    
    init(user: User) {
        self.user = user
        Task {
            try await fetchFollowingUserAndFollowerUser(withUid:user.id)
        }
        observeUserFollow()
    }
    
    // grab following user
    @MainActor
    func fetchFollowingUserAndFollowerUser(withUid uid: String) async throws {
        self.userFollow = try await UserService().fetchUserFollow(withUid: uid)
        self.followingUser = try await UserService().fetchFollowingUser(withUid: uid)
    }
    
    // follow user
    func followUser(followUserId otherUserId: String) {
        UserService().followUser(followUserId: otherUserId) {
        }
    }
    
    // unfollow user
    func unfollowUser(followUserId otherUserId: String) {
        UserService().unfollowUser(followUserId: otherUserId) {
        }
    }
    
    // observe user follow
    func observeUserFollow() {
        UserService().observeFollowerOrFollowing(collectionName: "user-follow") { user in
            if self.userFollow.contains(user) {
                self.userFollow = self.userFollow.filter({ $0 != user})
            }else {
                self.userFollow.append(user)
            }
        }
    }
}
