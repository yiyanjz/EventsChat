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
        checkIfUserStarPost()
        fetchUpdatePost()
    }
    
    // like post
    func likePost(){
        service.likePost(post) {
            self.post.didLike = true
        }
    }
    
    // unlike post
    func unlikePost(){
        service.unlikePost(post) {
            self.post.didLike = false
        }
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
        PostService.observePost { post in
            var temp_user = self.post.user
            var tempDidLike = self.post.didLike
            var tempDidStar = self.post.didStar
            self.post = post
            self.post.user = temp_user
            self.post.didLike = tempDidLike
            self.post.didStar = tempDidStar
        }
    }
    
    // star post
    func starPost() {
        service.starPost(post) {
            self.post.didStar = true
        }
    }
    
    // unstar post
    func unstarPost() {
        service.unstarPost(post) {
            self.post.didStar = false
        }
    }
    
    // check for prefilled stars
    func checkIfUserStarPost() {
        service.checkIfUserStaredPost(post) { didStar in
            if didStar {
                self.post.didStar = true
            }
        }
    }
}
