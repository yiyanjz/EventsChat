//
//  AllLikesViewModel.swift
//  EC
//
//  Created by Justin Zhang on 11/14/23.
//

import SwiftUI

class AllLikesViewModel: ObservableObject {
    @State var likedList: [String]
    
    init(likedList: [String]) {
        self.likedList = likedList
    }
    
    
}
