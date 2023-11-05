//
//  PreviewVideoView.swift
//  EC
//
//  Created by Justin Zhang on 11/3/23.
//

import SwiftUI
import AVFoundation
import _AVKit_SwiftUI

struct PreviewVideoView: View {
    var item: LibrayPhotos
    
    var body: some View {
        if let imageUrl = item.imageUrl {
            VideoPlayer(player: AVPlayer(url:  imageUrl))
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .ignoresSafeArea()
        }
    }
}
