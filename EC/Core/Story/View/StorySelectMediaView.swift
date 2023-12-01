//
//  StorySelectMediaView.swift
//  EC
//
//  Created by Justin Zhang on 11/29/23.
//

import SwiftUI

struct StorySelectMediaView: View {
    let screenHeight = UIScreen.main.bounds.height
    let screenWidth = UIScreen.main.bounds.width
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = StorySelectMediaViewModel()
    
    // grid Item Structure
    private let gridItem: [GridItem] = [
        .init(.flexible(), spacing: 4),
        .init(.flexible(), spacing: 4),
        .init(.flexible(), spacing: 4),
    ]

    var body: some View {
        NavigationStack {
            VStack {
                headerView
                
                bodyView
                
                Spacer()
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
            .fullScreenCover(isPresented: $viewModel.uploadProfileStory) {
                StoryTitleView(selectedMedia: viewModel.selectedMedia)
                    .NavigationHidden()
                    .onDisappear {
                        dismiss()
                    }
            }
        }
    }
}

struct StorySelectMediaView_Previews: PreviewProvider {
    static var previews: some View {
        StorySelectMediaView()
    }
}

extension StorySelectMediaView {
    // Header View
    var headerView: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "x.circle")
            }
            .padding(.horizontal, 5)
            
            Spacer()
            
            Text("Stories")
            
            Spacer()
            
            Button {
                viewModel.uploadProfileStory.toggle()
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
    
    var bodyView: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: gridItem, spacing: 1) {
                    ForEach(Array(viewModel.allList.enumerated()), id: \.element) { index, item in
                        if item.imageUrl != nil {
                            NavigationLink {
                                PreviewVideoView(item: item)
                            } label: {
                                Image(uiImage: item.uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: (screenWidth/3), height: (screenHeight/3)-30)
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
                                                .font(.title3)
                                                .foregroundColor(.white)
                                                .padding(5)
                                                .background(.black.opacity(0.5),in: Circle())
                                                .frame(width: 50, height: 50)
                                                .padding(8)
                                        }
                                        .offset(x: 45, y: -100)
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
                                    .frame(width: (screenWidth/3), height: (screenHeight/3)-30)
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
                                                .font(.title3)
                                                .foregroundColor(.white)
                                                .padding(5)
                                                .background(.black.opacity(0.5),in: Circle())
                                                .frame(width: 50, height: 50)
                                                .padding(8)
                                        }
                                        .offset(x: 45, y: -100)
                                    )
                            }
                        }
                    }
                }
            }
        }
    }
}
