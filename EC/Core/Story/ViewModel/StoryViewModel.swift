//
//  StoryViewModel.swift
//  EC
//
//  Created by Justin Zhang on 12/24/23.
//

import SwiftUI
import Firebase

class StoryViewModel: ObservableObject {
    @Published var browseButtonClicked: Bool = false
    @Published var showMoreActionSheet: Bool = false
    @Published var media: Story
    @Published var user: User
    @Published var selectedStory: Story?
    
    init(media: Story, user: User) {
        self.media = media
        self.user = user
        observeStoryModify(withStoryId: media.id)
    }
    
    // delete story
    func deleteProfileStory(withStory story: Story, deleteStoryIndex: Int) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        StoryService().deleteProfileStory(withUid: uid, withStory: story, deleteStoryIndex: deleteStoryIndex) {
        }
    }
    
    func observeStoryModify(withStoryId storyId: String) {
        StoryService().observeStoryModify(withStoryId: storyId) { [weak self] story in
            if story.id == self?.media.id {
                self?.media.selectedMedia = story.selectedMedia
            }
        }
    }
}
