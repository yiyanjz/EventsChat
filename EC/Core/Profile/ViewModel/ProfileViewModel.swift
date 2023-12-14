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
    
    let service = PostService()
        
    init(user: User, withBackButton: Bool) {
        self.user = user
        self.withBackButton = withBackButton
        fetchCurrentUser()
        fetchLikedPosts()
        fetchStaredPosts()
        fetchAllPosts()
        observeLikedPost()
        observeStarPost()
        observeAllPost()
        observeAllStory()
        observePostRemoved()
        fetchUpdateGrabUserPostsAndFollowingUser()
        Task {
            try await fetchAllStory()
            try await grabUserPostsAndFollowingUser()
        }
    }
    
    // listener for user infor changes
    func fetchCurrentUser() {
        UserService.observeUser(withUid: user.id) { user in
            self.user = user
        }
    }
    
    // filter likes
    func fetchLikedPosts() {
        service.fetchPostActionInfo(forUid: user.id, collectionName: CollectionFilter.userLiked.title) { posts in
            self.likedPosts = posts
            
            if self.likedPosts.count > 0 {
                for i in 0..<self.likedPosts.count {
                    let post = self.likedPosts[i]
                    if let ownerId = post.ownerId {
                        UserService.fetchUserCompletion(withUid: ownerId) { postUser in
                            self.likedPosts[i].user = postUser
                        }
                    }
                }
            }
        }
    }
    
    // filter stars
    func fetchStaredPosts() {
        service.fetchPostActionInfo(forUid: user.id, collectionName: CollectionFilter.userStared.title) { posts in
            self.starPosts = posts
            
            if self.starPosts.count > 0 {
                for i in 0..<self.starPosts.count {
                    let post = self.starPosts[i]
                    if let ownerId = post.ownerId {
                        UserService.fetchUserCompletion(withUid: ownerId) { postUser in
                            self.starPosts[i].user = postUser
                        }
                    }
                }
            }
        }
    }
    
    // filter posts
    func fetchAllPosts() {
        service.fetchPostActionInfo(forUid: user.id, collectionName: CollectionFilter.userPost.title) { [self] posts in
            self.allPosts = posts
            
            if self.allPosts.count > 0 {
                for i in 0..<self.allPosts.count {
                    self.allPosts[i].user = self.user
                }
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
        user.posts = postCount
        user.followering = userFollow
        user.followers = followingUserCount
        user.likes = userLikes
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
        }
    }
}
