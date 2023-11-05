//
//  PreviewPostViewModel.swift
//  EC
//
//  Created by Justin Zhang on 11/4/23.
//

import SwiftUI
import PhotosUI
import Firebase

class PreviewPostViewModel: ObservableObject {
    @Published var caption = ""
    @Published var captionTitle = ""
    @Published var selectedMedia: [LibrayPhotos]
    
    init(selectedMedia: [LibrayPhotos]) {
        self.selectedMedia = selectedMedia
    }
    
    func uploadPost() async throws {
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
        let post = Post(id: postRef.documentID, caption: caption, title: captionTitle, likes: 0, stars: 0, comments: 0, timestamp: Timestamp(), imagesUrl: mediaUrls, userId: uid)
        
        guard let encodedPost = try? Firestore.Encoder().encode(post) else {return}
        
        try await postRef.setData(encodedPost)
    }
}
