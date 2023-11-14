//
//  FollowViewModel.swift
//  EC
//
//  Created by Justin Zhang on 11/13/23.
//

import SwiftUI
import Firebase

class FollowViewModel: ObservableObject {
    private let service = PostService()
    @Published var post: Post
    @Published var likes: Int = 0
    
    init(post: Post) {
        self.post = post
        self.likes = self.post.likes
        checkIfUserLikedPost()
    }
    
    func likePost(){
        service.likePost(post) {
            self.post.didLike = true
            self.likes += 1
        }
    }
    
    func unlikePost(){
        service.unlikePost(post) {
            self.post.didLike = false
            self.likes -= 1
        }
    }
    
    func checkIfUserLikedPost() {
        service.checkIfUserLikedPost(post) { didLike in
            if didLike {
                self.post.didLike = true
            }
        }
    }
}
