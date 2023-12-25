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
    @Published var selectAlbum : ImageAlbumItem = ImageAlbumItem(number: 0, fetchResult: PHFetchResult<PHAsset>.init())
    @Published var storyTitle: String = ""
    
    // get albums
    public func getAlbum(){
        albumList = []
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            guard status == .authorized else {return}
            let smartOptions = PHFetchOptions()
            let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: smartOptions)
            let customAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: smartOptions)
            
            for i in 0..<smartAlbums.count {
                let album = smartAlbums[i]
                // fectch ablum photos, video etc
                let resultsOptions = PHFetchOptions()
                let assetsFetchResult = PHAsset.fetchAssets(in: album , options: resultsOptions)
                if assetsFetchResult.count > 0 {
                    let data = ImageAlbumItem(number: assetsFetchResult.count, title: album.localizedTitle, fetchResult: assetsFetchResult)
                    DispatchQueue.main.async {
                        self.albumList.append(data)
                    }
                }
            }
            
            for i in 0..<customAlbums.count {
                let album = customAlbums[i]
                // fectch ablum photos, video etc
                let resultsOptions = PHFetchOptions()
                let assetsFetchResult = PHAsset.fetchAssets(in: album , options: resultsOptions)
                if assetsFetchResult.count > 0 {
                    let data = ImageAlbumItem(number: assetsFetchResult.count, title: album.localizedTitle, fetchResult: assetsFetchResult)
                    DispatchQueue.main.async {
                        self.albumList.append(data)
                    }
                }
            }
            
            // display recent ablum first
            if self.selectAlbum.number == 0 {
                let idx = self.albumList.firstIndex { item in
                    item.title == "Recents"
                }
                if let idx = idx {
                    DispatchQueue.main.async {
                        self.selectAlbum = self.albumList[idx]
                    }
                }
            }
        }
    }
    
    // get images, videos from albums
    public func getImages(){
        allList = []
        selectedMedia = []
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        option.isSynchronous = true
        option.deliveryMode = .highQualityFormat
        let liveOption = PHLivePhotoRequestOptions()
        liveOption.deliveryMode = .highQualityFormat
        for i in 0..<selectAlbum.fetchResult.count {
            let fetchresult = selectAlbum.fetchResult[i]
            if fetchresult.mediaType == .image {
                manager.requestImage(for: selectAlbum.fetchResult.object(at: i), targetSize: UIScreen.main.bounds.size, contentMode: .aspectFill, options: option) { image, _ in
                    if let image = image {
                        DispatchQueue.main.async {
                            self.allList.append(LibrayPhotos(uiImage: image))
                        }
                    }
                }
            } else if fetchresult.mediaType == .video{
                manager.requestAVAsset(forVideo: selectAlbum.fetchResult.object(at: i), options: nil) { video, _, _ in
                    if video != nil {
                        let avasset = video as! AVURLAsset
                        let urlVideo = avasset.url
                        // create uiimage
                        let imageGenerator = AVAssetImageGenerator(asset: avasset)
                        let time = CMTimeMake(value: 1, timescale: 1)
                        let imageRef = try! imageGenerator.copyCGImage(at: time, actualTime: nil)
                        let thumbnail = UIImage(cgImage:imageRef)
                        // get video time length
                        let duration = avasset.duration
                        let durationTime = CMTimeGetSeconds(duration)
                        let minutes = durationTime/60
                        let videoDuration = String(format: "%.2f", minutes)
                        DispatchQueue.main.async {
                            self.allList.append(LibrayPhotos(uiImage: thumbnail, imageUrl: urlVideo, duration: videoDuration))
                        }
                    }
                }
            }
        }
    }
}

