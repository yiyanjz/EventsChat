//
//  CameraView.swift
//  EC
//
//  Created by Justin Zhang on 12/31/23.
//

import SwiftUI
import AVFoundation
import _AVKit_SwiftUI

struct CameraView: View {
    @StateObject var model = CameraViewModel()
    
    @State var currentZoomFactor: CGFloat = 1.0
    
    var captureButton: some View {
        Button(action: {}, label: {
            Circle()
                .foregroundColor(.white)
                .frame(width: 80, height: 80, alignment: .center)
                .overlay(
                    Circle()
                        .stroke(Color.black.opacity(0.8), lineWidth: 2)
                        .frame(width: 65, height: 65, alignment: .center)
                )
                .onTapGesture {
                    model.capturePhoto()
                }
                .onLongPressGesture(minimumDuration: 0.1) {
                    print("Long tap")
                    if model.isRecording {
                        model.stopRecording()
                    } else {
                        model.startRecording()
                    }
                }
        })
    }
    
    var capturedPhotoThumbnail: some View {
        // preview button
        Button {
            if let _ = model.previewURL {
                model.showPreview.toggle()
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
//        .opacity((model.previewURLRef == nil && model.recordedURLsRef.isEmpty) || model.isRecordingRef ? 0 : 1)
//        Group {
//            if model.photo != nil {
//                Image(uiImage: model.photo.image!)
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .frame(width: 60, height: 60)
//                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
//                
//            } else {
//                RoundedRectangle(cornerRadius: 10)
//                    .frame(width: 60, height: 60, alignment: .center)
//                    .foregroundColor(.black)
//            }
//        }
    }
    
    var flipCameraButton: some View {
        Button(action: {
            model.flipCamera()
        }, label: {
            Circle()
                .foregroundColor(Color.gray.opacity(0.2))
                .frame(width: 45, height: 45, alignment: .center)
                .overlay(
                    Image(systemName: "camera.rotate.fill")
                        .foregroundColor(.white))
        })
    }
    
    var body: some View {
        GeometryReader { reader in
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack {
                    Button(action: {
                        model.switchFlash()
                    }, label: {
                        Image(systemName: model.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                            .font(.system(size: 20, weight: .medium, design: .default))
                    })
                    .accentColor(model.isFlashOn ? .yellow : .white)
                    
                    CameraPreview(session: model.session)
                        .gesture(
                            DragGesture().onChanged({ (val) in
                                if abs(val.translation.height) > abs(val.translation.width) {
                                    let percentage: CGFloat = -(val.translation.height / reader.size.height)
                                    let calc = currentZoomFactor + percentage
                                    let zoomFactor: CGFloat = min(max(calc, 1), 5)
                                    currentZoomFactor = zoomFactor
                                    model.zoom(with: zoomFactor)
                                }
                            })
                        )
                        .onAppear {
                            model.configure()
                        }
                        .alert(isPresented: $model.showAlertError, content: {
                            Alert(title: Text(model.alertError.title), message: Text(model.alertError.message), dismissButton: .default(Text(model.alertError.primaryButtonTitle), action: {
                                model.alertError.primaryAction?()
                            }))
                        })
                        .overlay(
                            Group {
                                if model.willCapturePhoto {
                                    Color.black
                                }
                            }
                        )
                    
                    
                    HStack {
                        capturedPhotoThumbnail
                        
                        Spacer()
                        
                        captureButton
                        
                        Spacer()
                        
                        flipCameraButton
                        
                    }
                    .padding(.horizontal, 20)
                }
            }
            .fullScreenCover(isPresented: $model.showPreview, content: {
                if let url = model.previewURL, model.showPreview {
                    FinalPreview(url: url, showPreview: $model.showPreview)
                        .transition(.move(edge: .trailing))
                }
            })
        }
    }
}
#Preview {
    CameraView()
}


// camera preview
struct CameraPreview: UIViewRepresentable {
    class VideoPreviewView: UIView {
        override class var layerClass: AnyClass {
             AVCaptureVideoPreviewLayer.self
        }
        
        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            return layer as! AVCaptureVideoPreviewLayer
        }
    }
    
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> VideoPreviewView {
        let view = VideoPreviewView()
        view.backgroundColor = .black
        view.videoPreviewLayer.cornerRadius = 0
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.connection?.videoOrientation = .portrait

        return view
    }
    
    func updateUIView(_ uiView: VideoPreviewView, context: Context) {
        
    }
}

// MARk: Final Video Preview
struct FinalPreview: View {
    var url: URL
    @Binding var showPreview: Bool
    
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            
            VideoPlayer(player: AVPlayer(url: url))
                .aspectRatio(contentMode: .fill)
                .frame(width: size.width, height: size.height)
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .overlay(alignment: .topLeading) {
                    Button {
                        showPreview.toggle()
                    } label: {
                        Label {
                            Text("Back")
                        } icon: {
                            Image(systemName: "chevron.left")
                        }
                    }
                }
        }
    }
}
