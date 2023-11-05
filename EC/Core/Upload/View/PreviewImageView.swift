//
//  PreviewImageView.swift
//  EC
//
//  Created by Justin Zhang on 11/3/23.
//

import SwiftUI
import Kingfisher

struct PreviewImageView: View {
    var photo: LibrayPhotos
    
    var body: some View {
        Image(uiImage: photo.uiImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            .ignoresSafeArea()
    }
}
