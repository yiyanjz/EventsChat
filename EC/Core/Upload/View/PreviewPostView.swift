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
    @StateObject var viewModel: PreviewPostViewModel
    
    init(selectedMedia: [LibrayPhotos]) {
        self._viewModel = StateObject(wrappedValue: PreviewPostViewModel(selectedMedia: selectedMedia))
    }

    // grid Item Structure
    private let gridItem: [GridItem] = [
        .init(.flexible(), spacing: 2),
        .init(.flexible(), spacing: 2),
        .init(.flexible(), spacing: 2)
    ]
    
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
                        Task { try await viewModel.uploadPost() }
                        dismiss()
                    } label: {
                        Text("Post")
                            .font(.footnote)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                
                ScrollView {
                    VStack {
                        // media files
                        HStack {
                            LazyVGrid(columns: gridItem, spacing: 2) {
                                ForEach(viewModel.selectedMedia) { item in
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
                                        }
                                    }
                                }
                            }
                        }
                        
                        Divider()
                            .padding(4)
                        
                        // body view
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
                            }
                            
                            Divider()
                                .padding(4)

                            HStack {
                                let icon = Image(systemName: "location")
                                Text("\(icon) Location")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Image(systemName: "chevron.right")
                                    .font(.footnote)
                            }
                            
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
        }
    }
}

//struct PreviewPostView_Previews: PreviewProvider {
//    static var previews: some View {
//        PreviewPostView(selectedMedia: <#[UUID : LibrayPhotos]#>)
//    }
//}
