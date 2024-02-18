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
                if item.id == selectedCover.id {
                    selectedMediaUrl = videoUrl
                }
            }else {
                if item.id == selectedCover.id {
                    guard let imageCoverUrl = try await ImageUploader.uploadImage(image: selectedCover.uiImage, path: .postImages) else {return}
                    guard let imageUrl = try await ImageUploader.uploadImage(image: item.uiImage, path: .postImages) else {return}
                    mediaUrls.append(imageUrl)
                    selectedMediaUrl = imageCoverUrl
                } else {
                    guard let imageUrl = try await ImageUploader.uploadImage(image: item.uiImage, path: .postImages) else {return}
                    mediaUrls.append(imageUrl)
                }
            }
        }
        
        // then upload story
        let story = Story(id: storyRef.documentID, caption: caption, selectedMedia: mediaUrls, selectedCover: selectedMediaUrl, timestamp: Timestamp())
        guard let encodedStory = try? Firestore.Encoder().encode(story) else {return}
        try await storyRef.setData(encodedStory)
        
        // save story to user in firebase
        let userStoryRef = Firestore.firestore().collection("users").document(uid).collection("user-profile-storys")
        try await userStoryRef.document(story.id).setData([:])
    }
    
    // upload to feed story
    func uploadSingleProfileStory(item:LibrayPhotos) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let storyRef = Firestore.firestore().collection("storys").document()
        
        // upload media
        var mediaUrls = ""
        if item.imageUrl != nil {
            guard let itemUrl = item.imageUrl else {return}
            let videoData = try Data(contentsOf: itemUrl)
            guard let videoUrl = try await VideoUploader.uploadVideo(withData:videoData, path: .postVideo) else {return}
            mediaUrls = videoUrl
        }else {
            guard let imageUrl = try await ImageUploader.uploadImage(image: item.uiImage, path: .postImages) else {return}
            mediaUrls = imageUrl
        }
        
        // upload story
        let story = SingleStory(id: storyRef.documentID, selectedMedia: mediaUrls, timestamp: Timestamp(), ownerId: uid)
        guard let encodedStory = try? Firestore.Encoder().encode(story) else {return}
        try await storyRef.setData(encodedStory)
        
        // save story to firebase
        let userStoryRef = Firestore.firestore().collection("users").document(uid).collection("user-main-storys")
        try await userStoryRef.document(story.id).setData([:])
    }
    
    // fetch profile storys
    static func fetchProfileStorys(forUid uid:String) async throws -> [Story] {
        let snapshot = try await Firestore.firestore().collection("users").document(uid).collection("user-profile-storys").getDocuments()
        
        var profileStorys = [Story]()
        for document in snapshot.documents {
            let storyId = document.documentID
            let storySnapshot = try await Firestore.firestore().collection("storys").document(storyId).getDocument()
            let story = try storySnapshot.data(as: Story.self)
            profileStorys.append(story)
        }
        return profileStorys
    }
    
    // observe profile story
    static func observeStorysAdd(forUid uid:String, completion: @escaping(Story) -> Void) {
        Firestore.firestore().collection("users").document(uid).collection("user-profile-storys").addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else { return }

            snapshot.documentChanges.forEach { documentChange in
                if documentChange.type == .added {
                    let docId = documentChange.document.documentID
                    Firestore.firestore().collection("storys").document(docId).getDocument { querySnapshot, _ in
                        guard let snapshot = querySnapshot else { return }
                        guard let story = try? snapshot.data(as: Story.self) else {return}
                        completion(story)
                    }
                }
            }
        }
    }
    
    // observe profile story removed
    static func observeStorysRemoved(forUid uid:String, completion: @escaping(String) -> Void) {
        Firestore.firestore().collection("users").document(uid).collection("user-profile-storys").addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else { return }

            snapshot.documentChanges.forEach { documentChange in
                if documentChange.type == .removed {
                    let storyId = documentChange.document.documentID
                    completion(storyId)
                }
            }
        }
    }
    
    // delete story
    func deleteProfileStory(withUid uid: String, withStory story: Story, deleteStoryIndex: Int, completion: @escaping() -> Void) {
        var story = story
        let storyRef = Firestore.firestore().collection("storys").document(story.id)
        story.selectedMedia.remove(at: deleteStoryIndex)
        
        if story.selectedMedia.count > 0 {
            Firestore.firestore().collection("storys").document(story.id).updateData(["selectedMedia": story.selectedMedia]) { _ in
            }
        } else {
            storyRef.delete()
            let userStoryRef = Firestore.firestore().collection("users").document(uid).collection("user-profile-storys").document(story.id)
            userStoryRef.delete()
        }
    }
    
    // check for modify posts (Not Used)
    func observeStoryModify(withStoryId storyId: String, completion: @escaping(Story) -> Void) {        
        Firestore.firestore().collection("storys").document(storyId).addSnapshotListener { querySnapshot, error in
            guard let document = querySnapshot else {return}
            guard let data = try? document.data(as: Story.self) else {return}
            completion(data)
        }
    }
    
    // query all storys that user follows
    func QueryUserMainStory() async throws -> [SingleStory] {
        guard let uid = Firebase.Auth.auth().currentUser?.uid else {return []}
        let snapshot = try await Firestore.firestore().collection("users").document(uid).collection("user-main-storys").getDocuments()
        var mainStories = [SingleStory]()
        
        for document in snapshot.documents {
            let storyId = document.documentID
            let storySnapshot = try await Firestore.firestore().collection("storys").document(storyId).getDocument()
            let story = try storySnapshot.data(as: SingleStory.self)
            mainStories.append(story)
        }
        
        return mainStories
    }
}
