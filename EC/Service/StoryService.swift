//
//  StoryService.swift
//  EC
//
//  Created by Justin Zhang on 11/29/23.
//

import SwiftUI
import Photos
import AVKit
import Firebase

struct StoryService {
    func uploadProfileStory(selectedMedia: [LibrayPhotos], selectedCover: LibrayPhotos, caption:String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        guard !selectedMedia.isEmpty else {return}
        let storyRef = Firestore.firestore().collection("storys").document()
        
        // upload images
        var mediaUrls = [String]()
        var selectedMediaUrl: String = ""
        for idx in 0..<selectedMedia.count {
            let item = selectedMedia[idx]
            if item.imageUrl != nil {
                guard let itemUrl = item.imageUrl else {return}
                let videoData = try Data(contentsOf: itemUrl)
                guard let videoUrl = try await VideoUploader.uploadVideo(withData:videoData, path: .postVideo) else {return}
                mediaUrls.append(videoUrl)
                if item == selectedCover {
                    selectedMediaUrl = videoUrl
                }
            }else {
                guard let imageUrl = try await ImageUploader.uploadImage(image: item.uiImage, path: .postImages) else {return}
                mediaUrls.append(imageUrl)
                if item == selectedCover {
                    selectedMediaUrl = imageUrl
                }
            }
        }
        
        // then upload story
        let story = Story(id: storyRef.documentID, caption: caption, selectedMedia: mediaUrls, selectedCover: selectedMediaUrl)
        guard let encodedStory = try? Firestore.Encoder().encode(story) else {return}
        try await storyRef.setData(encodedStory)
        
        // save story to user in firebase
        let userStoryRef = Firestore.firestore().collection("users").document(uid).collection("user-profile-storys")
        try await userStoryRef.document(story.id).setData([:])
    }
}
