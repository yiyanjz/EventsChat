//
//  FollowViewModel.swift
//  EC
//
//  Created by Justin Zhang on 11/13/23.
//

import SwiftUI
import Firebase

class FollowViewModel: ObservableObject {
    @Published var post: Post
    
    init(post: Post) {
        self.post = post
    }

}
