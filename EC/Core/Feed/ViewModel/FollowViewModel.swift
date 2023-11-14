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
    @Published var showAllLikes: Bool = false
    
    init(post: Post) {
        self.post = post
        checkIfUserLikedPost()
        fetchUpdatePost()
    }
    
    func likePost(){
        print("\(post.likes)")
        service.likePost(post) {
            self.post.didLike = true
        }
    }
    
    func unlikePost(){
        print("\(post.likes)")
        service.unlikePost(post) {
            self.post.didLike = false
        }
    }
    
    func checkIfUserLikedPost() {
        service.checkIfUserLikedPost(post) { didLike in
            if didLike {
                self.post.didLike = true
            }
        }
    }
    
    // listener for modified changes
    func fetchUpdatePost(){
        PostService.observePost { post in
            self.post = post
        }
    }
}
