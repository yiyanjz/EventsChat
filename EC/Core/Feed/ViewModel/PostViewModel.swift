//
//  PostViewModel.swift
//  EC
//
//  Created by Justin Zhang on 11/14/23.
//

import SwiftUI
import Firebase

class PostViewModel: ObservableObject {
    private let service = PostService()
    @Published var post: Post

    init(post: Post) {
        self.post = post
        checkIfUserLikedPost()
        fetchUpdatePost()
    }
    
    // like post
    func likePost(){
        service.likePost(post){}
    }
    
    // unlike post
    func unlikePost(){
        service.unlikePost(post){}
    }
    
    // check for prefilled likes
    func checkIfUserLikedPost() {
        service.checkIfUserLikedPost(post) { didLike in
            if didLike {
                self.post.didLike = true
            }
        }
    }
    
    // listener for modified changes
    func fetchUpdatePost(){
        service.observeCurrentPost(withPostID: post.id) { post in
            let temp_user = self.post.user
            self.post = post
            self.post.user = temp_user
        }
    }
}
