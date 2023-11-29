//
//  OtherUserProfileViewModel.swift
//  EC
//
//  Created by Justin Zhang on 11/28/23.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift
import Combine


class OtherUserProfileViewModel: ObservableObject {
    @Published var user: User
    @Published var allPosts = [Post]()
    @Published var staredPosts = [Post]()
    @Published var showPostDetails: Bool = false
    @Published var selectedPost: Post?
    
    let service = PostService()

    init(user: User) {
        self.user = user
        fetchallUsersPosts()
        fetchallUserStars()
    }
    
    func fetchallUsersPosts() {
        service.fetchPostActionInfo(forUid: user.id, collectionName: CollectionFilter.userPost.title) { [self] posts in
            self.allPosts = posts
            
            for i in 0..<posts.count {
                self.allPosts[i].user = self.user
            }
        }
    }
    
    func fetchallUserStars() {
        service.fetchPostActionInfo(forUid: user.id, collectionName: CollectionFilter.userStared.title) { [self] posts in
            self.staredPosts = posts
            
            for i in 0..<posts.count {
                let post = posts[i]
                if let ownerId = post.ownerId {
                    UserService.fetchUserCompletion(withUid: ownerId) { postUser in
                        self.staredPosts[i].user = postUser
                    }
                }
            }
        }
    }
}
