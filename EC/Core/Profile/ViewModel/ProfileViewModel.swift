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
            
            for i in 0..<posts.count {
                let post = posts[i]
                if let ownerId = post.ownerId {
                    UserService.fetchUserCompletion(withUid: ownerId) { postUser in
                        self.likedPosts[i].user = postUser
                    }
                }
            }
        }
    }
    
    // filter stars
    func fetchStaredPosts() {
        service.fetchPostActionInfo(forUid: user.id, collectionName: CollectionFilter.userStared.title) { posts in
            self.starPosts = posts
            
            for i in 0..<posts.count {
                let post = posts[i]
                if let ownerId = post.ownerId {
                    UserService.fetchUserCompletion(withUid: ownerId) { postUser in
                        self.starPosts[i].user = postUser
                    }
                }
            }
        }
    }
    
    // filter posts
    func fetchAllPosts() {
        service.fetchPostActionInfo(forUid: user.id, collectionName: CollectionFilter.userPost.title) { [self] posts in
            self.allPosts = posts
            
            for i in 0..<posts.count {
                self.allPosts[i].user = self.user
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
}
