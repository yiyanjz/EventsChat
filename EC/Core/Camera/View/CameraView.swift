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
    @Environment (\.dismiss) var dismiss
    
    @State var currentZoomFactor: CGFloat = 1.0
    
    var captureButton: some View {
        Button(action: {}, label: {
            Circle()
                .foregroundColor(.white)
                .frame(width: 70, height: 70, alignment: .center)
                .overlay(
                    Circle()
                        .stroke(Color.black.opacity(0.8), lineWidth: 2)
                        .frame(width: 55, height: 55, alignment: .center)
                )
                .onTapGesture {
                    model.capturePhoto()
                    model.doneWithCamera.toggle()
                }
                .gesture(
                    LongPressGesture(minimumDuration: 0.5)
                        .onEnded { _ in /// 0.5 seconds is over, start recording
                            if model.isRecording == false {
                                model.startRecording()
                                if model.isFlashOn {
                                    model.toggleTorch(on: true)
                                }
                            }
                        }
                        .sequenced(before: DragGesture(minimumDistance: 0))
                        .onEnded { _ in /// finger lifted, stop recording
                            if model.isRecording == true {
                                model.stopRecording()
                            }
                            if model.isFlashOn {
                                model.toggleTorch(on: false)
                            }
                            model.recordedDuration = 0
                            model.doneWithCamera.toggle()
                            model.doneRecording.toggle()
                            model.freezeCamera()
                        }
                )
                .padding(.vertical)
        })
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
    
    var flashButton: some View {
        Button(action: {
            model.switchFlash()
        }, label: {
            Image(systemName: model.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                .font(.system(size: 20, weight: .medium, design: .default))
        })
        .accentColor(model.isFlashOn ? .yellow : .white)
    }
    
    var cancelButton: some View {
        if model.doneWithCamera {
            Button {
                if model.doneRecording && model.doneWithCamera {
                    model.doneWithCamera.toggle()
                    model.doneRecording.toggle()
                    model.mediaSaved = false
                    model.previewURL = nil
                    model.recordedURLs.removeAll()
                    model.startCamera()
                } else if model.doneWithCamera {
                    model.doneWithCamera.toggle()
                    model.photo?.originalData = Data()
                    model.doneTakingFlashPhoto = false
                    model.mediaSaved = false
                    model.doneTakingNormalPhoto = false
                    model.startCamera()
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title)
                    .foregroundStyle(.white)
            }
        } else {
            Button {
                model.recordedDuration = 0
                model.previewURL = nil
                model.recordedURLs.removeAll()
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.title)
                    .foregroundStyle(.white)
            }
        }
    }
    
    var saveToLibraryButton: some View {
        Button {
            if model.mediaSaved == false {
                model.saveImageToLibaray()
                model.mediaSaved.toggle()
            }
        } label: {
            Image(systemName: model.mediaSaved ? "checkmark" : "square.and.arrow.down")
                .frame(width: 50, height: 50)
                .background(.gray.opacity(0.2),in: RoundedRectangle(cornerRadius: 20))
        }
    }
    
    var addToStoryButton: some View {
        Button {
            
        } label: {
            let icon = Image(systemName: "plus")
            
            Text("\(icon) Story")
                .frame(width: 200, height: 50)
                .font(.system(size: 15))
                .background(.gray.opacity(0.2),in: RoundedRectangle(cornerRadius: 20))
        }
    }
    
    var body: some View {
        GeometryReader { reader in
            let size = reader.size

            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                // timer zone
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(.black.opacity(0.25))
                    
                    Rectangle()
                        .fill(Color(uiColor: .red))
                        .frame(width: size.width * (model.recordedDuration / model.maxDuration))
                }
                .frame(height: 10)
                .frame(maxHeight: .infinity, alignment: .top)
                
                VStack {
                    HStack {
                        // cancel button
                        cancelButton
                        
                        Spacer()
                        
                        // flash button
                        flashButton
                        
                        Spacer()
                            
                        // flip camera button
                        flipCameraButton
                    }
                    .padding(.horizontal)
                    
                    ZStack {
                        VStack {
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
                        }
                        .opacity(model.doneTakingFlashPhoto || model.doneRecording ? 0 : 1)
                        
                        VStack {
                            if let previewURL = model.previewURL {
                                let video: (player: AVPlayer, looper: AVPlayerLooper)  = {
                                    let asset = AVAsset(url: previewURL)
                                    let item = AVPlayerItem(asset: asset)
                                    let queuePlayer = AVQueuePlayer(playerItem: item)
                                    let playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: item)
                                    
                                    return (queuePlayer, playerLooper)
                                }()
                                
                                VideoPlayer(player: video.player)
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: size.width)
                                    .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                                    .onAppear {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                            video.player.play()
                                        })
                                    }
                                    .onDisappear{
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                            video.player.pause()
                                        })
                                    }
                            }
                        }
                        .opacity(model.doneRecording ? 1 : 0)
                        
                        VStack {
                            if let imageData = model.photo?.originalData, let image = UIImage(data: imageData) {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: size.width)
                                    .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                            }
                        }
                        .opacity(model.doneTakingFlashPhoto ? 1 : 0)
                    }
                    
                    ZStack {
                        HStack {
                            Spacer()
                            
                            captureButton
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .opacity(model.doneTakingNormalPhoto || model.doneTakingFlashPhoto || model.doneRecording  ? 0 : 1)
                        
                        HStack {
                            // save to library button
                            saveToLibraryButton
                            
                            // add to story button
                            addToStoryButton
                        }
                        .opacity(model.doneTakingNormalPhoto || model.doneTakingFlashPhoto || model.doneRecording  ? 1 : 0)
                    }
                    .background(.gray.opacity(0.2),in: RoundedRectangle(cornerRadius: 20))
                }
            }
            .onReceive(Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()) { _ in
                if model.recordedDuration <= model.maxDuration && model.isRecording {
                    model.recordedDuration += 0.1
                }
                
                if model.recordedDuration >= model.maxDuration && model.isRecording {
                    model.stopRecording()
                    model.isRecording = false
                }
            }
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
        view.videoPreviewLayer.videoGravity = .resizeAspectFill

        return view
    }
    
    func updateUIView(_ uiView: VideoPreviewView, context: Context) {
        
    }
}
