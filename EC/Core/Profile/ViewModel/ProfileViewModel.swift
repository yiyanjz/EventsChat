//
//  ProfileViewModel.swift
//  EC
//
//  Created by Justin Zhang on 11/2/23.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift
import Combine


class ProfileViewModel: ObservableObject {
    @Published var user: User
    @Published var likedPosts = [Post]()
    @Published var allPosts = [Post]()
    @Published var starPosts = [Post]()
    @Published var showSharedCard: Bool = false
    @Published var showPostDetails: Bool = false
    @Published var selectedPost: Post?
    @Published var withBackButton: Bool
    @Published var showStoryView: Bool = false
    @Published var profileStorys = [Story]()
    @Published var showProfileStory: Bool = false
    @Published var selectedProfileStory: Story?
    @Published var showProfileInfo: Bool = false
    @Published var actionButtonClicked: Bool = false // not used

    let service = PostService()
        
    init(user: User, withBackButton: Bool) {
        self.user = user
        self.withBackButton = withBackButton
        fetchCurrentUser()
        observeLikedPost()
        observeStarPost()
        observeAllPost()
        observeAllStory()
        observePostRemoved()
        fetchUpdateGrabUserPostsAndFollowingUser()
        Task {
            try await fetchAllStory()
            try await grabUserPostsAndFollowingUser()
            try await fetchAllPost(user: user)
            try await fetchStaredPosts(user: user)
            try await fetchLikedPosts(user: user)
        }
    }
    
    // listener for user infor changes
    func fetchCurrentUser() {
        UserService.observeUser(withUid: user.id) { user in
            self.user = user
        }
    }
    
    @MainActor
    // fetch all liked posts
    func fetchLikedPosts(user: User) async throws {
        let posts = try await service.fetchPostActionInfo(forUid: user.id, collectionName: CollectionFilter.userLiked.title)
        self.likedPosts = posts
        
        if self.likedPosts.count > 0 {
            for i in 0..<self.likedPosts.count {
                let post = self.likedPosts[i]
                if let ownwerID = post.ownerId {
                    let postUser = try await UserService.fetchUser(withUid: ownwerID)
                    self.likedPosts[i].user = postUser
                }
            }
        }
    }
    
    @MainActor
    // fetch all stared posts
    func fetchStaredPosts(user: User) async throws {
        let posts = try await service.fetchPostActionInfo(forUid: user.id, collectionName: CollectionFilter.userStared.title)
        self.starPosts = posts
        
        if self.starPosts.count > 0 {
            for i in 0..<self.starPosts.count {
                let post = self.starPosts[i]
                if let ownwerID = post.ownerId {
                    let postUser = try await UserService.fetchUser(withUid: ownwerID)
                    self.starPosts[i].user = postUser
                }
            }
        }
    }
    
    @MainActor
    // fetch all posts
    func fetchAllPost(user: User) async throws {
        let posts = try await service.fetchPostActionInfo(forUid: user.id, collectionName: CollectionFilter.userPost.title)
        self.allPosts = posts
        
        if self.allPosts.count > 0 {
            for i in 0..<self.allPosts.count {
                self.allPosts[i].user = user
            }
        }
    }
    
    // observe likes filter
    func observeLikedPost() {
        service.observePostsActionInfo(forUid: user.id, collectionName: CollectionFilter.userLiked.title) { post in
            guard let postDidLike = post.didLike else {return}
            if postDidLike {
                self.likedPosts.append(post)
            } else if !postDidLike{
                self.likedPosts = self.likedPosts.filter({ $0.id != post.id})
            }
        }
    }
    
    // observe star filter
    func observeStarPost() {
        service.observePostsActionInfo(forUid: user.id, collectionName: CollectionFilter.userStared.title) { post in
            guard let postDidStar = post.didStar else {return}
            if postDidStar {
                self.starPosts.append(post)
            } else if !postDidStar {
                self.starPosts = self.starPosts.filter({ $0.id != post.id})
            }
        }
    }
    
    // observe post filter
    func observeAllPost() {
        service.observePostsActionInfo(forUid: user.id, collectionName: CollectionFilter.userPost.title) { post in
            self.allPosts.append(post)
        }
    }
    
    // fetch all profile stories
    @MainActor
    func fetchAllStory() async throws{
        self.profileStorys = try await StoryService.fetchProfileStorys(forUid: user.id)
    }
    
    // observe for new storys
    func observeAllStory() {
        StoryService.observeStorysAdd(forUid: user.id) { story in
            self.profileStorys.append(story)
        }
    }
    
    // grab user posts + following user
    @MainActor
    func grabUserPostsAndFollowingUser() async throws{
        let postCount = try await UserService().grabUserPosts(withUid: user.id)
        let followingUserCount = try await UserService().grabFollowingUser(withUid: user.id)
        let userFollow = try await UserService().grabUserFollow(withUid: user.id)
        let userLikes = try await UserService().grabUserLikes(withUid: user.id)
        self.user.posts = postCount
        self.user.followering = userFollow
        self.user.followers = followingUserCount
        self.user.likes = userLikes
    }
    
    func fetchUpdateGrabUserPostsAndFollowingUser() {
        UserService().fetchUpdateUserPosts(withUid: user.id) { postCount in
            self.user.posts = postCount
        }
        UserService().fetchUpdateFollowingUser(withUid: user.id) { userFollow in
            self.user.followers = userFollow
        }
        UserService().fetchUpdateUserFollow(withUid: user.id) { followingUserCount in
            self.user.followering = followingUserCount
        }
        UserService().fetchUpdateUserLikes(withUid: user.id) { userLikes in
            self.user.likes = userLikes
        }
    }
    
    // observePostRemoved
    func observePostRemoved() {
        PostService.observePostsRemoved { post in
            self.allPosts = self.allPosts.filter({ $0.id != post.id})
            self.likedPosts = self.likedPosts.filter({ $0.id != post.id})
            self.starPosts = self.starPosts.filter({ $0.id != post.id})
        }
    }
}
