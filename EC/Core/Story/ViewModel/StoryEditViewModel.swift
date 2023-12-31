//
//  StoryEditViewModel.swift
//  EC
//
//  Created by Justin Zhang on 12/25/23.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift
import Combine
import Photos
import AVKit

class StoryEditViewModel: ObservableObject {
    @Published var allList: [LibrayPhotos] = []
    @Published var selectedMedia = [LibrayPhotos]()
    @Published var albumList: [ImageAlbumItem] = []
    @Published var selectedImage: LibrayPhotos?
    @Published var selectAlbum : ImageAlbumItem = ImageAlbumItem(number: 0, fetchResult: PHFetchResult<PHAsset>.init())
    @Published var story: Story
    @Published var showImageEditor: Bool = false
    
    init(media: Story) {
        self.story = media
        turnStringToLibrayPhotos(storyUrl: media.selectedMedia)
    }
    
    func turnStringToLibrayPhotos(storyUrl: [String]){
        for url in storyUrl {
            let url = URL(string: url)
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: url!)
                DispatchQueue.main.async {
                    if let image = UIImage(data: data!) {
                        let librayP = LibrayPhotos(uiImage: image, selected: true)
                        self.selectedMedia.append(librayP)
                    }
                }
            }
        }
    }
}

