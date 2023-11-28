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
    
    let service = PostService()
        
    init(user: User) {
        self.user = user
        fetchCurrentUser()
        fetchLikedPosts()
        observeLikedPost()
    }
    
    func postFilter(forFilter filter: ProfileFilter) -> [Post] {
        switch filter {
        case .posts:
            return allPosts
        case .likes:
            return likedPosts
        case .stars:
            return starPosts
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
        service.fetchLikedPosts(forUid: user.id) { posts in
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
    
    // observe likes filter
    func observeLikedPost() {
        service.observeLikedPost(forUid: user.id) { post in
            guard let postDidLike = post.didLike else {return}
            if postDidLike {
                self.likedPosts.append(post)
            } else if !postDidLike{
                self.likedPosts = self.likedPosts.filter({ $0.id != post.id})
            }
        }
    }
}
