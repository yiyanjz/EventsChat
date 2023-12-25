//
//  StoryViewModel.swift
//  EC
//
//  Created by Justin Zhang on 12/24/23.
//

import SwiftUI

class StoryViewModel: ObservableObject {
    @Published var browseButtonClicked: Bool = false
    @Published var showMoreActionSheet: Bool = false
    @Published var media: Story
    @Published var user: User
    @Published var selectedStory: Story?
    
    init(media: Story, user: User) {
        self.media = media
        self.user = user
    }
}
