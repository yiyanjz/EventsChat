//
//  StoryTitleView.swift
//  EC
//
//  Created by Justin Zhang on 11/30/23.
//

import SwiftUI
import Kingfisher

struct StoryTitleView: View {
    let screenHeight = UIScreen.main.bounds.height
    let screenWidth = UIScreen.main.bounds.width
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: StoryTitleViewModel
    
    init(selectedMedia: [LibrayPhotos], completStory: Binding<Bool>) {
        self._viewModel = StateObject(wrappedValue:StoryTitleViewModel(selectedMedia: selectedMedia, completStory: completStory))
    }
    
    var body: some View {
        VStack {
            headerView
            
            bodyView
            
            Spacer()
            
            imageSelectionView
        }
        .fullScreenCover(isPresented: $viewModel.showEditCover) {
            ImageEditor(theImage: $viewModel.selectedStoryCoverImage, isShowing: $viewModel.showEditCover)
                .ignoresSafeArea()
        }
    }
}

struct StoryTitleView_Previews: PreviewProvider {
    static var previews: some View {
        StoryTitleView(selectedMedia: [LibrayPhotos(uiImage: UIImage(named: "shin")!)], completStory: .constant(false))
    }
}

extension StoryTitleView {
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
            
            Text("Story Title")
            
            Spacer()
            
            Button {
                Task { try await viewModel.uploadProfileStory(selectedStoryCoverImage: viewModel.selectedStoryCoverImage) }
                dismiss()
                viewModel.completStory.toggle()
            } label: {
                Text("Add")
            }
        }
        .padding()
        .foregroundColor(colorScheme == .light ? .black : .white)
    }
    
    var bodyView: some View {
        VStack {
            Button {
                viewModel.showEditCover.toggle()
            } label: {
                VStack {
                    if let firstImage = viewModel.selectedStoryCoverImage?.uiImage {
                        Image(uiImage: firstImage)
                            .resizable()
                            .frame(width: 200, height: 200)
                            .clipShape(Circle())
                            .foregroundColor(Color(.systemGray4))
                        
                        Text("Edit Cover")
                    }
                }
            }
            
            TextField("Story Title", text: $viewModel.storyTitle)
                .multilineTextAlignment(.center)
                
        }
    }
    
    var imageSelectionView: some View {
        HStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(viewModel.selectedMedia, id: \.self) { librayPhoto in
                        Button {
                            viewModel.selectedStoryCoverImage = librayPhoto
                        } label: {
                            Image(uiImage: librayPhoto.uiImage)
                                .resizable()
                                .frame(width: 70, height: 70)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(
                                    librayPhoto == viewModel.selectedStoryCoverImage
                                    ? RoundedRectangle(cornerRadius: 16)
                                        .stroke(.white, lineWidth: 2)
                                    : RoundedRectangle(cornerRadius: 16)
                                        .stroke(.clear, lineWidth: 2)
                                )
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}
