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
    
    init(selectedMedia: [LibrayPhotos]) {
        self._viewModel = StateObject(wrappedValue:StoryTitleViewModel(selectedMedia: selectedMedia))
    }
    
    var body: some View {
        VStack {
            headerView
            
            bodyView
            
            Spacer()
        }
        .fullScreenCover(isPresented: $viewModel.showEditCover) {
            StoryCoverEditView(images: viewModel.selectedMedia, selectedImage: $viewModel.selectedStoryCoverImage)
        }
    }
}

struct StoryTitleView_Previews: PreviewProvider {
    static var previews: some View {
        StoryTitleView(selectedMedia: [LibrayPhotos(uiImage: UIImage(named: "shin")!)])
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
                Task { try await viewModel.uploadProfileStory() }
                dismiss()
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
}
