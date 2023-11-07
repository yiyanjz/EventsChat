//
//  UploadView.swift
//  EC
//
//  Created by Justin Zhang on 11/2/23.
//

import SwiftUI
import Photos
import AVKit

struct UploadView: View {
    @State private var selectedFilter: UploadFilter = .allItems
    @Environment(\.colorScheme) var colorScheme
    @State var showMoreAblum: Bool = false
    @State var albumList: [ImageAlbumItem] = []
    @State var selectAlbum : ImageAlbumItem = ImageAlbumItem(number: 0, fetchResult: PHFetchResult<PHAsset>.init())
    @State var allList: [LibrayPhotos] = []
    @Binding var mainTabBarSelected: TabBarSelection
    @Binding var showTabBar: Bool
    @State var selectedMedia = [LibrayPhotos]()
    @State var previewPost: Bool = false
    @State var completePost: Bool = false
    @State var draggedItemSheet: LibrayPhotos?
    @State var hasChangedLocationSheet: Bool = false
    
    // grid Item Structure
    private let gridItem: [GridItem] = [
        .init(.flexible(), spacing: 1),
        .init(.flexible(), spacing: 1),
        .init(.flexible(), spacing: 1)
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                // header
                HStack {
                    Button {
                        mainTabBarSelected = .feed
                        showTabBar = true
                    } label: {
                        Image(systemName: "x.circle")
                    }
                    .padding(.top, 8)
                    .padding(.horizontal, 5)
                    
                    Spacer()
                    
                    Menu {
                        ForEach(albumList, id:\.self) { album in
                            Button {
                                selectAlbum = album
                            } label: {
                                Text(album.title ?? "")
                            }
                        }
                    }label: {
                        HStack {
                            Text(selectAlbum.title ?? "Recents")
                            
                            Image(systemName: showMoreAblum ? "chevron.up":"chevron.down")
                                .font(.footnote)
                        }
                        .frame(width: 100)
                    }
                    
                    Spacer()
                    
                    Button {
                        previewPost.toggle()
                    } label: {
                        if selectedMedia.count > 0 {
                            Text("Next \(selectedMedia.count)")
                                .font(.footnote)
                        }else{
                            Text("Next")
                                .font(.footnote)
                        }
                    }
                }
                .padding()
                .foregroundColor(colorScheme == .light ? .black : .white)
                
                // upload filters
                HStack(spacing: 15) {
                    ForEach(UploadFilter.allCases, id: \.rawValue) { item in
                        VStack{
                            Text(item.title)
                                .font(.caption)
                                .fontWeight(selectedFilter == item ? .semibold : .regular)
                                .foregroundColor(colorScheme == .light ? .black : .white)
                                // .frame == underline's height .offset = underlines y's pos
                                .background( selectedFilter == item ? Color.red.frame(width: 60, height: 2).offset(y: 14)
                                             : Color.clear.frame(width: 30, height: 1).offset(y: 14)
                                )
                        }
                        .onTapGesture {
                            withAnimation(.easeInOut) {
                                selectedFilter = item
                            }
                        }
                        .padding(.horizontal, 25)
                    }
                }
                
                Divider()
                
                TabView(selection: $selectedFilter) {
                    allAlbum
                        .tag(UploadFilter.allItems)
                    albumVideoView
                        .tag(UploadFilter.video)
                    albumImageView
                        .tag(UploadFilter.photo)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                if selectedMedia.count > 0 {
                    sheetView
                }
            }
            .onAppear {
                DispatchQueue.main.async{
                    getAlbum()
                }
            }
            .onChange(of: selectAlbum) { newValue in
                DispatchQueue.main.async{
                    getImages()
                }
            }
            .fullScreenCover(isPresented: $previewPost) {
                PreviewPostView(selectedMedia: $selectedMedia, completePost: $completePost)
                    .onDisappear {
                        if completePost {
                            mainTabBarSelected = .feed
                            showTabBar = true
                            completePost.toggle()
                            selectedMedia = []
                            getImages()
                        }
                    }
            }
        }
    }
}

struct UploadView_Previews: PreviewProvider {
    static var previews: some View {
        UploadView(mainTabBarSelected: .constant(.upload), showTabBar: .constant(true))
    }
}

struct ImageAlbumItem : Identifiable,Equatable,Hashable{
    var id = UUID()
    var number : Int
    var title : String?
    var fetchResult : PHFetchResult<PHAsset>
}

struct LibrayPhotos: Identifiable, Hashable {
    var id = UUID()
    var uiImage: UIImage
    var imageUrl: URL?
    var duration: String?
    var selected: Bool = false
}

extension UploadView {
    var albumImageView: some View {
        ScrollView {
            LazyVGrid(columns: gridItem, spacing: 2) {
                ForEach(Array(allList.enumerated()), id: \.element) { index, item in
                    if item.imageUrl == nil {
                        NavigationLink {
                            PreviewImageView(photo: item)
                        } label: {
                            Image(uiImage: item.uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: UIScreen.main.bounds.width / 3 - 5,height: UIScreen.main.bounds.width / 3 - 5)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .overlay(
                                    Button {
                                        if allList[index].selected == false && selectedMedia.count < 9 {
                                            allList[index].selected.toggle()
                                            let media = allList[index]
                                            selectedMedia.append(media)
                                        }else if allList[index].selected || selectedMedia.count > 9 {
                                            allList[index].selected.toggle()
                                            let media = allList[index]
                                            if selectedMedia.contains(where: { key in key.id == media.id }) {
                                                selectedMedia.removeAll(where: { key in key.id == media.id })
                                            }
                                        }
                                    } label: {
                                        Image(systemName: item.selected ? "checkmark.seal.fill" : "checkmark.seal")
                                            .font(.footnote)
                                            .foregroundColor(.white)
                                            .padding(5)
                                            .background(.black.opacity(0.5),in: Circle())
                                            .frame(width: 30, height: 30)
                                            .padding(8)
                                    }
                                    .offset(x: 38, y: -40)
                                )
                        }
                    }
                }
            }
        }
    }
    
    var albumVideoView: some View {
        ScrollView {
            LazyVGrid(columns: gridItem, spacing: 2) {
                ForEach(Array(allList.enumerated()), id: \.element) { index, item in
                    if item.imageUrl != nil {
                        NavigationLink {
                            PreviewVideoView(item: item)
                        } label: {
                            Image(uiImage: item.uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: UIScreen.main.bounds.width / 3 - 5,height: UIScreen.main.bounds.width / 3 - 5)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .overlay(
                                    Button {
                                        if allList[index].selected == false && selectedMedia.count < 9 {
                                            allList[index].selected.toggle()
                                            let media = allList[index]
                                            selectedMedia.append(media)
                                        }else if allList[index].selected || selectedMedia.count > 9 {
                                            allList[index].selected.toggle()
                                            let media = allList[index]
                                            if selectedMedia.contains(where: { key in key.id == media.id }) {
                                                selectedMedia.removeAll(where: { key in key.id == media.id })
                                            }
                                        }
                                    } label: {
                                        Image(systemName: item.selected ? "checkmark.seal.fill" : "checkmark.seal")
                                            .font(.footnote)
                                            .foregroundColor(.white)
                                            .padding(5)
                                            .background(.black.opacity(0.5),in: Circle())
                                            .frame(width: 30, height: 30)
                                            .padding(8)
                                    }
                                    .offset(x: 38, y: -40)
                                )
                                .overlay(
                                    Text(item.duration ?? "")
                                        .font(.footnote)
                                        .foregroundColor(.white)
                                        .frame(maxWidth:.infinity,maxHeight: .infinity,alignment: .bottomTrailing)
                                        .padding(8)
                                )
                        }
                    }
                }
            }
        }
    }
    
    var allAlbum: some View {
        ScrollView {
            LazyVGrid(columns: gridItem, spacing: 2) {
                ForEach(Array(allList.enumerated()), id: \.element) { index, item in
                    if item.imageUrl != nil {
                        NavigationLink {
                            PreviewVideoView(item: item)
                        } label: {
                            Image(uiImage: item.uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: UIScreen.main.bounds.width / 3 - 5,height: UIScreen.main.bounds.width / 3 - 5)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .overlay(
                                    Button {
                                        if allList[index].selected == false && selectedMedia.count < 9 {
                                            allList[index].selected.toggle()
                                            let media = allList[index]
                                            selectedMedia.append(media)
                                        }else if allList[index].selected || selectedMedia.count > 9 {
                                            allList[index].selected.toggle()
                                            let media = allList[index]
                                            if selectedMedia.contains(where: { key in key.id == media.id }) {
                                                selectedMedia.removeAll(where: { key in key.id == media.id })
                                            }
                                        }
                                    } label: {
                                        Image(systemName: item.selected ? "checkmark.seal.fill" : "checkmark.seal")
                                            .font(.footnote)
                                            .foregroundColor(.white)
                                            .padding(5)
                                            .background(.black.opacity(0.5),in: Circle())
                                            .frame(width: 30, height: 30)
                                            .padding(8)
                                    }
                                    .offset(x: 38, y: -40)
                                )
                                .overlay(
                                    Text(item.duration ?? "")
                                        .font(.footnote)
                                        .foregroundColor(.white)
                                        .frame(maxWidth:.infinity,maxHeight: .infinity,alignment: .bottomTrailing)
                                        .padding(8)
                                )
                        }
                    } else {
                        NavigationLink {
                            PreviewImageView(photo: item)
                        } label: {
                            Image(uiImage: item.uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: UIScreen.main.bounds.width / 3 - 5,height: UIScreen.main.bounds.width / 3 - 5)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .overlay(
                                    Button {
                                        if allList[index].selected == false && selectedMedia.count < 9 {
                                            allList[index].selected.toggle()
                                            let media = allList[index]
                                            selectedMedia.append(media)
                                        }else if allList[index].selected || selectedMedia.count > 9 {
                                            allList[index].selected.toggle()
                                            let media = allList[index]
                                            if selectedMedia.contains(where: { key in key.id == media.id }) {
                                                selectedMedia.removeAll(where: { key in key.id == media.id })
                                            }
                                        }
                                    } label: {
                                        Image(systemName: item.selected ? "checkmark.seal.fill" : "checkmark.seal")
                                            .font(.footnote)
                                            .foregroundColor(.white)
                                            .padding(5)
                                            .background(.black.opacity(0.5),in: Circle())
                                            .frame(width: 30, height: 30)
                                            .padding(8)
                                    }
                                    .offset(x: 38, y: -40)
                                )
                        }
                    }
                }
            }
        }
    }
    
    var sheetView: some View {
        VStack{
            ScrollView(.horizontal, showsIndicators: false){
                HStack{
                    ForEach(selectedMedia) { item in
                        if item.imageUrl != nil {
                            NavigationLink {
                                PreviewVideoView(item: item)
                            } label: {
                                Image(uiImage: item.uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                    .overlay(
                                        Text(item.duration ?? "")
                                            .font(.footnote)
                                            .foregroundColor(.white)
                                            .frame(maxWidth:.infinity,maxHeight: .infinity,alignment: .bottomTrailing)
                                            .padding(8)
                                    )
                                    .overlay(
                                        Button {
                                            selectedMedia.removeAll(where: { key in key.id == item.id })
                                            let allListIdx = allList.firstIndex(where: {key in key.id == item.id })
                                            if let allListIdx = allListIdx, allList[allListIdx].selected == true {
                                                allList[allListIdx].selected.toggle()
                                            }
                                        } label: {
                                            Image(systemName: "x.circle.fill")
                                                .font(.footnote)
                                                .foregroundColor(.white)
                                                .padding(5)
                                                .frame(width: 20, height: 20)
                                                .padding(8)
                                        }
                                        .offset(x: 38, y: -40)
                                    )
                                    .onDrag {
                                        draggedItemSheet = item
                                        return NSItemProvider(object: ("\(item.id) media") as NSString)
                                    }
                                    .onDrop(of: [.text],
                                            delegate: DropViewDelegate(destinationItem:item, media:$selectedMedia, draggedItem:$draggedItemSheet, hasChangedLocation: $hasChangedLocationSheet)
                                    )
                                    .overlay(draggedItemSheet?.id == item.id && hasChangedLocationSheet ? Color(uiColor: .systemBackground).opacity(1) : Color.clear)
                                
                            }
                        }else{
                            NavigationLink {
                                PreviewImageView(photo: item)
                            } label: {
                                Image(uiImage: item.uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                    .overlay(
                                        Button {
                                            selectedMedia.removeAll(where: { key in key.id == item.id })
                                            let allListIdx = allList.firstIndex(where: {key in key.id == item.id })
                                            if let allListIdx = allListIdx, allList[allListIdx].selected == true {
                                                allList[allListIdx].selected.toggle()
                                            }
                                        } label: {
                                            Image(systemName: "x.circle.fill")
                                                .font(.footnote)
                                                .foregroundColor(.white)
                                                .padding(5)
                                                .frame(width: 20, height: 20)
                                                .padding(8)
                                        }
                                        .offset(x: 38, y: -40)
                                    )
                                    .onDrag {
                                        draggedItemSheet = item
                                        return NSItemProvider(object: ("\(item.id) media") as NSString)
                                    }
                                    .onDrop(of: [.text],
                                            delegate: DropViewDelegate(destinationItem:item, media:$selectedMedia, draggedItem:$draggedItemSheet, hasChangedLocation: $hasChangedLocationSheet)
                                    )
                                    .overlay(draggedItemSheet?.id == item.id && hasChangedLocationSheet ? Color(uiColor: .systemBackground).opacity(1) : Color.clear)
                            }
                        }
                    }
                }
                .padding()
                .onDrop(of: [.text], delegate: DropOutsideDelegate(draggedItem: $draggedItemSheet, hasChangedLocation: $hasChangedLocationSheet))
            }
        }
        .frame(width: UIScreen.main.bounds.width, height: 100)
    }
}


extension UploadView {
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
                    self.albumList.append(data)
                }
            }
            
            for i in 0..<customAlbums.count {
                let album = customAlbums[i]
                // fectch ablum photos, video etc
                let resultsOptions = PHFetchOptions()
                let assetsFetchResult = PHAsset.fetchAssets(in: album , options: resultsOptions)
                if assetsFetchResult.count > 0 {
                    let data = ImageAlbumItem(number: assetsFetchResult.count, title: album.localizedTitle, fetchResult: assetsFetchResult)
                    self.albumList.append(data)
                }
            }
            
            // display recent ablum first
            if self.selectAlbum.number == 0 {
                let idx = albumList.firstIndex { item in
                    item.title == "Recents"
                }
                if let idx = idx {
                    self.selectAlbum = albumList[idx]
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
                        allList.append(LibrayPhotos(uiImage: image))
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
                        allList.append(LibrayPhotos(uiImage: thumbnail, imageUrl: urlVideo, duration: videoDuration))
                    }
                }
            }
        }
    }
}
