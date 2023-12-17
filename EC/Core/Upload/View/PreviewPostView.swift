//
//  PreviewPostView.swift
//  EC
//
//  Created by Justin Zhang on 11/3/23.
//

import SwiftUI

struct PreviewPostView: View {
    @Environment (\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel = PreviewPostViewModel()
    @Binding var completePost: Bool
    @Binding var selectedMedia: [LibrayPhotos]
    
    init(selectedMedia: Binding<[LibrayPhotos]>, completePost: Binding<Bool>) {
        self._selectedMedia = selectedMedia
        self._completePost = completePost
    }

    // grid Item Structure
    private let gridItem: [GridItem] = [
        .init(.flexible(), spacing: 2),
        .init(.flexible(), spacing: 2),
        .init(.flexible(), spacing: 2)
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
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .font(.footnote)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Spacer()
                    
                    Button {
                        Task { try await viewModel.uploadPost(selectedMedia: selectedMedia) }
                        completePost.toggle()
                        dismiss()
                    } label: {
                        Text("Post")
                            .font(.footnote)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                
                ScrollView(showsIndicators: false) {
                    VStack {
                        // media files
                        VStack {
                            LazyVGrid(columns: gridItem, spacing: 2) {
                                ForEach(selectedMedia) { item in
                                    if item.imageUrl != nil {
                                        NavigationLink {
                                            PreviewVideoView(item: item)
                                        } label: {
                                            Image(uiImage: item.uiImage)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 120, height: 120)
                                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                                .overlay(
                                                    Text(item.duration ?? "")
                                                        .font(.footnote)
                                                        .foregroundColor(.white)
                                                        .frame(maxWidth:.infinity,maxHeight: .infinity,alignment: .bottomTrailing)
                                                        .padding(8)
                                                )
                                                .onDrag {
                                                    viewModel.draggedItem = item
                                                    let provider = MYItemProvider(contentsOf: URL(string: "\(item.id)"))!
                                                    provider.didEnd = {
                                                        DispatchQueue.main.async {
                                                            viewModel.hasChangedLocation = false
                                                        }
                                                    }
                                                    return provider
                                                }
                                                .onDrop(of: [.text],
                                                        delegate: DropViewDelegate(destinationItem:item, media:$selectedMedia, draggedItem:$viewModel.draggedItem, hasChangedLocation: $viewModel.hasChangedLocation)
                                                )
                                                .opacity(viewModel.draggedItem?.id == item.id && viewModel.hasChangedLocation ? 0 : 1)
                                        }
                                    }else{
                                        NavigationLink {
                                            PreviewImageView(photo: item)
                                        } label: {
                                            Image(uiImage: item.uiImage)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 120, height: 120)
                                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                                .onDrag {
                                                    viewModel.draggedItem = item
                                                    let provider = MYItemProvider(contentsOf: URL(string: "\(item.id)"))!
                                                    provider.didEnd = {
                                                        DispatchQueue.main.async {
                                                            viewModel.hasChangedLocation = false
                                                        }
                                                    }
                                                    return provider
                                                }
                                                .onDrop(of: [.text],
                                                        delegate: DropViewDelegate(destinationItem:item, media:$selectedMedia, draggedItem:$viewModel.draggedItem, hasChangedLocation: $viewModel.hasChangedLocation)
                                                )
                                                .opacity(viewModel.draggedItem?.id == item.id && viewModel.hasChangedLocation ? 0 : 1)
                                        }
                                    }
                                }
                            }
                            .animation(.default, value: selectedMedia)
                        }
                        .onDrop(of: [.text], delegate: DropOutsideDelegate(draggedItem: $viewModel.draggedItem, hasChangedLocation: $viewModel.hasChangedLocation))
                        
                        Divider()
                            .padding(4)
                        
                        // body view
                        VStack {
                            VStack {
                                VStack {
                                    // text field
                                    TextField("Add Title", text: $viewModel.captionTitle, axis: .horizontal)
                                        .textInputAutocapitalization(.none)
                                        .font(.subheadline)
                                        .lineLimit(1)
                                }
                                
                                Divider()
                                    .padding(4)

                                VStack {
                                    // text field
                                    TextField("Add Text", text: $viewModel.caption, axis: .vertical)
                                        .textInputAutocapitalization(.none)
                                        .font(.subheadline)
                                        .frame(minHeight: 70, alignment:.topLeading)
                                }
                                
                                Divider()
                                    .padding(4)
                            }
                            
                            // add Tag
                            HStack {
                                Button {
                                    viewModel.showTagView.toggle()
                                } label: {
                                    let icon = Image(systemName: "tag")
                                    Text("\(icon) Tags")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Text(viewModel.tagsInputText)
                                        .font(.footnote)
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.footnote)
                                }
                            }
                            .foregroundColor(colorScheme == .light ? .black : .white )
                            
                            Divider()
                                .padding(4)

                            // add location
                            HStack {
                                Button {
                                    viewModel.showLocationView.toggle()
                                } label: {
                                    let icon = Image(systemName: "location")
                                    Text("\(icon) Location")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Text(viewModel.mapSelectionLocation?.name ?? "")
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.footnote)
                                }
                            }
                            .foregroundColor(colorScheme == .light ? .black : .white )
                            
                            Divider()
                                .padding(4)

                            HStack{
                                let icon = Image(systemName: "at")
                                Text("\(icon) Mention")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Image(systemName: "chevron.right")
                                    .font(.footnote)
                            }
                            
                            Divider()
                                .padding(4)

                            HStack{
                                let icon = Image(systemName: "person.fill.badge.plus")
                                Text("\(icon) Visible To")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text("All")
                                    .font(.footnote)
                                    .foregroundColor(colorScheme == .light ? .black : .white )

                                Image(systemName: "chevron.right")
                                    .font(.footnote)
                            }
                            
                            Divider()
                                .padding(4)
                        }
                    }
                    .padding()
                }

                Spacer()
            }
            .fullScreenCover(isPresented: $viewModel.showTagView) {
                TagView(tagsInputText: $viewModel.tagsInputText)
            }
            .fullScreenCover(isPresented: $viewModel.showLocationView, content: {
                if #available(iOS 17.0, *) {
                    LocationView(mapSelectionLocation: $viewModel.mapSelectionLocation)
                } else {
                    // Fallback on earlier versions
                }
            })
        }
    }
}

//struct PreviewPostView_Previews: PreviewProvider {
//    static var previews: some View {
//        PreviewPostView(selectedMedia: <#[UUID : LibrayPhotos]#>)
//    }
//}
