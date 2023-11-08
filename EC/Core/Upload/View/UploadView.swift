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
    @StateObject var viewModel = UploadViewModel()
    @Environment(\.colorScheme) var colorScheme
    @Binding var mainTabBarSelected: TabBarSelection
    @Binding var showTabBar: Bool
    
    // grid Item Structure
    private let gridItem: [GridItem] = [
        .init(.flexible(), spacing: 1),
        .init(.flexible(), spacing: 1),
        .init(.flexible(), spacing: 1)
    ]
    
    class MYItemProvider: NSItemProvider {
        var didEnd: (() -> Void)?
        deinit {
            didEnd?()
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // header
                headerView
                
                // upload filters
                HStack(spacing: 15) {
                    ForEach(UploadFilter.allCases, id: \.rawValue) { item in
                        VStack{
                            Text(item.title)
                                .font(.caption)
                                .fontWeight(viewModel.selectedFilter == item ? .semibold : .regular)
                                .foregroundColor(colorScheme == .light ? .black : .white)
                                // .frame == underline's height .offset = underlines y's pos
                                .background( viewModel.selectedFilter == item ? Color.red.frame(width: 60, height: 2).offset(y: 14)
                                             : Color.clear.frame(width: 30, height: 1).offset(y: 14)
                                )
                        }
                        .onTapGesture {
                            withAnimation(.easeInOut) {
                                viewModel.selectedFilter = item
                            }
                        }
                        .padding(.horizontal, 25)
                    }
                }
                
                Divider()
                
                TabView(selection: $viewModel.selectedFilter) {
                    allAlbum
                        .tag(UploadFilter.allItems)
                    albumVideoView
                        .tag(UploadFilter.video)
                    albumImageView
                        .tag(UploadFilter.photo)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                if viewModel.selectedMedia.count > 0 {
                    sheetView
                }
            }
            .onAppear {
                DispatchQueue.main.async{
                    viewModel.getAlbum()
                }
            }
            .onChange(of: viewModel.selectAlbum) { newValue in
                DispatchQueue.main.async{
                    viewModel.getImages()
                }
            }
            .fullScreenCover(isPresented: $viewModel.previewPost) {
                PreviewPostView(selectedMedia: $viewModel.selectedMedia, completePost: $viewModel.completePost)
                    .onDisappear {
                        if viewModel.completePost {
                            mainTabBarSelected = .feed
                            showTabBar = true
                            viewModel.completePost.toggle()
                            viewModel.selectedMedia = []
                            viewModel.getImages()
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

// ImageAlbumItem Model
struct ImageAlbumItem : Identifiable,Equatable,Hashable{
    var id = UUID()
    var number : Int
    var title : String?
    var fetchResult : PHFetchResult<PHAsset>
}

// LibrayPhotos Model
struct LibrayPhotos: Identifiable, Hashable {
    var id = UUID()
    var uiImage: UIImage
    var imageUrl: URL?
    var duration: String?
    var selected: Bool = false
}

// extensions views
extension UploadView {
    // Header View
    var headerView: some View {
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
                ForEach(viewModel.albumList, id:\.self) { album in
                    Button {
                        viewModel.selectAlbum = album
                    } label: {
                        Text(album.title ?? "")
                    }
                }
            }label: {
                HStack {
                    Text(viewModel.selectAlbum.title ?? "Recents")
                    
                    Image(systemName: viewModel.showMoreAblum ? "chevron.up":"chevron.down")
                        .font(.footnote)
                }
                .frame(width: 100)
            }
            
            Spacer()
            
            Button {
                viewModel.previewPost.toggle()
            } label: {
                if viewModel.selectedMedia.count > 0 {
                    Text("Next \(viewModel.selectedMedia.count)")
                        .font(.footnote)
                }else{
                    Text("Next")
                        .font(.footnote)
                }
            }
        }
        .padding()
        .foregroundColor(colorScheme == .light ? .black : .white)
    }
    
    // album Image View
    var albumImageView: some View {
        ScrollView {
            LazyVGrid(columns: gridItem, spacing: 2) {
                ForEach(Array(viewModel.allList.enumerated()), id: \.element) { index, item in
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
                                        if viewModel.allList[index].selected == false && viewModel.selectedMedia.count < 9 {
                                            viewModel.allList[index].selected.toggle()
                                            let media = viewModel.allList[index]
                                            viewModel.selectedMedia.append(media)
                                        }else if viewModel.allList[index].selected || viewModel.selectedMedia.count > 9 {
                                            viewModel.allList[index].selected.toggle()
                                            let media = viewModel.allList[index]
                                            if viewModel.selectedMedia.contains(where: { key in key.id == media.id }) {
                                                viewModel.selectedMedia.removeAll(where: { key in key.id == media.id })
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
    
    // album video View
    var albumVideoView: some View {
        ScrollView {
            LazyVGrid(columns: gridItem, spacing: 2) {
                ForEach(Array(viewModel.allList.enumerated()), id: \.element) { index, item in
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
                                        if viewModel.allList[index].selected == false && viewModel.selectedMedia.count < 9 {
                                            viewModel.allList[index].selected.toggle()
                                            let media = viewModel.allList[index]
                                            viewModel.selectedMedia.append(media)
                                        }else if viewModel.allList[index].selected || viewModel.selectedMedia.count > 9 {
                                            viewModel.allList[index].selected.toggle()
                                            let media = viewModel.allList[index]
                                            if viewModel.selectedMedia.contains(where: { key in key.id == media.id }) {
                                                viewModel.selectedMedia.removeAll(where: { key in key.id == media.id })
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
    
    // all album view
    var allAlbum: some View {
        ScrollView {
            LazyVGrid(columns: gridItem, spacing: 2) {
                ForEach(Array(viewModel.allList.enumerated()), id: \.element) { index, item in
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
                                        if viewModel.allList[index].selected == false && viewModel.selectedMedia.count < 9 {
                                            viewModel.allList[index].selected.toggle()
                                            let media = viewModel.allList[index]
                                            viewModel.selectedMedia.append(media)
                                        }else if viewModel.allList[index].selected || viewModel.selectedMedia.count > 9 {
                                            viewModel.allList[index].selected.toggle()
                                            let media = viewModel.allList[index]
                                            if viewModel.selectedMedia.contains(where: { key in key.id == media.id }) {
                                                viewModel.selectedMedia.removeAll(where: { key in key.id == media.id })
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
                                        if viewModel.allList[index].selected == false && viewModel.selectedMedia.count < 9 {
                                            viewModel.allList[index].selected.toggle()
                                            let media = viewModel.allList[index]
                                            viewModel.selectedMedia.append(media)
                                        }else if viewModel.allList[index].selected || viewModel.selectedMedia.count > 9 {
                                            viewModel.allList[index].selected.toggle()
                                            let media = viewModel.allList[index]
                                            if viewModel.selectedMedia.contains(where: { key in key.id == media.id }) {
                                                viewModel.selectedMedia.removeAll(where: { key in key.id == media.id })
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
    
    // sheet view
    var sheetView: some View {
        VStack{
            ScrollView(.horizontal, showsIndicators: false){
                HStack{
                    ForEach(viewModel.selectedMedia) { item in
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
                                            viewModel.selectedMedia.removeAll(where: { key in key.id == item.id })
                                            let allListIdx = viewModel.allList.firstIndex(where: {key in key.id == item.id })
                                            if let allListIdx = allListIdx, viewModel.allList[allListIdx].selected == true {
                                                viewModel.allList[allListIdx].selected.toggle()
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
                                        viewModel.draggedItemSheet = item
                                        let provider = MYItemProvider(contentsOf: URL(string: "\(item.id)"))!
                                        provider.didEnd = {
                                            DispatchQueue.main.async {
                                                viewModel.hasChangedLocationSheet = false
                                            }
                                        }
                                        return provider
                                    }
                                    .onDrop(of: [.text],
                                            delegate: DropViewDelegate(destinationItem:item, media:$viewModel.selectedMedia, draggedItem:$viewModel.draggedItemSheet, hasChangedLocation: $viewModel.hasChangedLocationSheet)
                                    )
                                    .opacity(viewModel.draggedItemSheet?.id == item.id && viewModel.hasChangedLocationSheet ? 0 : 1)
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
                                            viewModel.selectedMedia.removeAll(where: { key in key.id == item.id })
                                            let allListIdx = viewModel.allList.firstIndex(where: {key in key.id == item.id })
                                            if let allListIdx = allListIdx, viewModel.allList[allListIdx].selected == true {
                                                viewModel.allList[allListIdx].selected.toggle()
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
                                        viewModel.draggedItemSheet = item
                                        let provider = MYItemProvider(contentsOf: URL(string: "\(item.id)"))!
                                        provider.didEnd = {
                                            DispatchQueue.main.async {
                                                viewModel.hasChangedLocationSheet = false
                                            }
                                        }
                                        return provider
                                    }
                                    .onDrop(of: [.text],
                                            delegate: DropViewDelegate(destinationItem:item, media:$viewModel.selectedMedia, draggedItem:$viewModel.draggedItemSheet, hasChangedLocation: $viewModel.hasChangedLocationSheet)
                                    )
                                    .opacity(viewModel.draggedItemSheet?.id == item.id && viewModel.hasChangedLocationSheet ? 0 : 1)
                            }
                        }
                    }
                }
                .padding()
                .onDrop(of: [.text], delegate: DropOutsideDelegate(draggedItem: $viewModel.draggedItemSheet, hasChangedLocation: $viewModel.hasChangedLocationSheet))
            }
        }
        .frame(width: UIScreen.main.bounds.width, height: 100)
    }
}
