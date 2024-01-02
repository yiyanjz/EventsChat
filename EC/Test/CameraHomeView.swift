//
//  CameraHomeView.swift
//  EC
//
//  Created by Justin Zhang on 1/1/24.
//

import SwiftUI
import AVKit

struct CameraHomeView: View {
    @StateObject var cameraModel = CameraVideoViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack(alignment: .bottom) {
            CameraTest()
                .environmentObject(cameraModel)
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .padding(.top)
                .padding(.bottom)
            
            ZStack {
                // capture button
                Button {
                    if cameraModel.isRecording {
                        cameraModel.stopRecording()
                    } else {
                        cameraModel.startRecording()
                    }
                } label: {
                    Image(systemName: "person")
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(.black)
                        .opacity(cameraModel.isRecording ? 0 : 1)
                        .padding(12)
                        .frame(width: 60, height: 60)
                        .background{
                            Circle()
                                .stroke(cameraModel.isRecording ? .clear : .black)
                        }
                        .background{
                            Circle()
                                .fill(cameraModel.isRecording ? .red : .white)
                        }
                }
                
                // preview button
                Button {
                    if let _ = cameraModel.previewURL {
                        cameraModel.showPreview.toggle()
                    }
                } label: {
                    Label {
                        Image(systemName: "chevron.right")
                            .font(.callout)
                    } icon: {
                        Text("Preview")
                    }
                    .foregroundStyle(.black)
                    .padding(.horizontal)
                    .padding(.vertical)
                    .background{
                        Capsule()
                            .fill(.white)
                    }
                }
                .frame(maxWidth: .infinity, alignment:.trailing)
                .padding(.bottom)
                .opacity((cameraModel.previewURL == nil && cameraModel.recordedURLs.isEmpty) || cameraModel.isRecording ? 0 : 1)
            }
            
            Button {
                cameraModel.recordedDuration = 0
                cameraModel.previewURL = nil
                cameraModel.recordedURLs.removeAll()
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.title)
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding()
            .padding(.top)

        }
        .fullScreenCover(isPresented: $cameraModel.showPreview, content: {
            if let url = cameraModel.previewURL, cameraModel.showPreview {
                FinalPreview(url: url, showPreview: $cameraModel.showPreview)
                    .transition(.move(edge: .trailing))
            }
        })
    }
}

#Preview {
    CameraHomeView()
}


//// MARk: Final Video Preview
//struct FinalPreview: View {
//    var url: URL
//    @Binding var showPreview: Bool
//    
//    var body: some View {
//        GeometryReader { proxy in
//            let size = proxy.size
//            
//            VideoPlayer(player: AVPlayer(url: url))
//                .aspectRatio(contentMode: .fill)
//                .frame(width: size.width, height: size.height)
//                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
//                .overlay(alignment: .topLeading) {
//                    Button {
//                        showPreview.toggle()
//                    } label: {
//                        Label {
//                            Text("Back")
//                        } icon: {
//                            Image(systemName: "chevron.left")
//                        }
//                    }
//                }
//        }
//    }
//}
