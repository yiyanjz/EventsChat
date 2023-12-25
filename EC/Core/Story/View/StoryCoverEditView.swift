//
//  StoryCoverEditView.swift
//  EC
//
//  Created by Justin Zhang on 11/30/23.
//

import SwiftUI

struct StoryCoverEditView: View {
    let screenHeight = UIScreen.main.bounds.height
    let screenWidth = UIScreen.main.bounds.width
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @State var images: [LibrayPhotos]
    @Binding var selectedImage: LibrayPhotos?
    
    var body: some View {
        VStack {
            ZStack {
                imageView

                VStack {
                    headerView
                    
                    Spacer()
                    
                    Spacer()
                    
                    Spacer()
                    
                    bodyView
                    
                    Spacer()
                }
            }
        }
        .onAppear {
            self.selectedImage = images.first
        }
    }
}

struct StoryCoverEditView_Previews: PreviewProvider {
    static var previews: some View {
        StoryCoverEditView(images: [LibrayPhotos(uiImage: UIImage(named: "shin")!)], selectedImage: .constant(LibrayPhotos(uiImage: UIImage(named: "shin")!)))
    }
}

extension StoryCoverEditView {
    // Header View
    var headerView: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Text("Cancel")
            }
            .padding(.horizontal, 5)
            
            Spacer()
            
            Text("Edit Cover")
            
            Spacer()
            
            Button {
                guard let selectedImage = selectedImage else {return}
                images.removeAll(where: {$0 == selectedImage})
                images.insert(selectedImage, at: 0)
                dismiss()
            } label: {
                Text("Next")
            }
        }
        .padding()
        .padding(.top,35)
        .foregroundColor(colorScheme == .light ? .black : .white)
    }
    
    var imageView: some View {
        VStack{
            if let selectedImage = selectedImage{
                Image(uiImage: selectedImage.uiImage)
                    .resizable()
                    .frame(width: screenWidth, height: screenHeight)
                    .ignoresSafeArea()
            }
        }
    }
    
    var bodyView: some View {
        HStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(images, id: \.self) { librayPhoto in
                        Button {
                            selectedImage = librayPhoto
                        } label: {
                            Image(uiImage: librayPhoto.uiImage)
                                .resizable()
                                .frame(width: 70, height: 70)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(
                                    librayPhoto == selectedImage
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
