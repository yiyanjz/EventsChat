//
//  StoryTitleViewModel.swift
//  EC
//
//  Created by Justin Zhang on 11/30/23.
//

import SwiftUI

class StoryTitleViewModel: ObservableObject {
    @Published var storyTitle: String = ""
    @Published var selectedMedia: [LibrayPhotos]
    @Published var showEditCover: Bool = false
    @Published var selectedStoryCoverImage: LibrayPhotos?
    
    init(selectedMedia: [LibrayPhotos]) {
        self.selectedMedia = selectedMedia
    }

}
