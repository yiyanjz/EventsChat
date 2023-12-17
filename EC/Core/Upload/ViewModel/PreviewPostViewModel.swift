//
//  PreviewPostViewModel.swift
//  EC
//
//  Created by Justin Zhang on 11/4/23.
//

import SwiftUI
import PhotosUI
import Firebase
import MapKit

class PreviewPostViewModel: ObservableObject {
    @Published var caption = ""
    @Published var captionTitle = ""
    @Published var draggedItem: LibrayPhotos?
    @Published var hasChangedLocation: Bool = false
    @Published var tagsInputText: String = ""
    @Published var showTagView: Bool = false
    @Published var showLocationView: Bool = false
    @Published var mapSelectionLocation: MKMapItem?
    
    func uploadPost(selectedMedia: [LibrayPhotos]) async throws {
        var mediaUrls = [String]()
        guard let uid = Auth.auth().currentUser?.uid else {return}
        guard !selectedMedia.isEmpty else {return}
        
        let postRef = Firestore.firestore().collection("posts").document()
        for idx in 0..<selectedMedia.count {
            let item = selectedMedia[idx]
            if item.imageUrl != nil {
                guard let itemUrl = item.imageUrl else {return}
                let videoData = try Data(contentsOf: itemUrl)
                guard let videoUrl = try await VideoUploader.uploadVideo(withData:videoData, path: .postVideo) else {return}
                mediaUrls.append(videoUrl)
            }else {
                guard let imageUrl = try await ImageUploader.uploadImage(image: item.uiImage, path: .postImages) else {return}
                mediaUrls.append(imageUrl)
            }
        }
        let post = Post(id: postRef.documentID, caption: caption, title: captionTitle, likes: 0, stars: 0, comments: 0, timestamp: Timestamp(), imagesUrl: mediaUrls, ownerId: uid)
        
        guard let encodedPost = try? Firestore.Encoder().encode(post) else {return}
        
        try await postRef.setData(encodedPost)
        
        // save post to user in firebase
        let userPostRef = Firestore.firestore().collection("users").document(uid).collection("user-posts")
        try await userPostRef.document(post.id).setData([:])
    }
}

struct DropViewDelegate: DropDelegate {
    let destinationItem: LibrayPhotos
    @Binding var media: [LibrayPhotos]
    @Binding var draggedItem: LibrayPhotos?
    @Binding var hasChangedLocation: Bool
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        withAnimation {
            hasChangedLocation = false
            draggedItem = nil
        }
        return true
    }
    
    func dropEntered(info: DropInfo) {
        // Swap Items
        if let draggedItem {
            let fromIndex = media.firstIndex(of: draggedItem)
            if let fromIndex {
                let toIndex = media.firstIndex(of: destinationItem)
                if let toIndex, fromIndex != toIndex {
                    hasChangedLocation = true
                    self.media.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: (toIndex > fromIndex ? (toIndex + 1) : toIndex))
                }
            }
        }
    }
}

struct DropOutsideDelegate: DropDelegate {
    @Binding var draggedItem: LibrayPhotos?
    @Binding var hasChangedLocation: Bool
        
    func dropEntered(info: DropInfo) {
        hasChangedLocation = true
    }
    
    func performDrop(info: DropInfo) -> Bool {
        hasChangedLocation = false
        draggedItem = nil
        return true
    }
}
