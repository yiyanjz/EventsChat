//
//  CameraTest.swift
//  EC
//
//  Created by Justin Zhang on 1/1/24.
//

import SwiftUI
import AVFoundation

struct CameraTest: View {
    @EnvironmentObject var cameraModel: CameraVideoViewModel
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            
            CameraVideoModelPreview(size: size)
                .environmentObject(cameraModel)
            
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(.black.opacity(0.25))
                
                Rectangle()
                    .fill(Color(uiColor: .red))
                    .frame(width: size.width * (cameraModel.recordedDuration / cameraModel.maxDuration))
            }
            .frame(height: 10)
            .frame(maxHeight: .infinity, alignment: .top)
            
        }
        .onAppear(perform: cameraModel.checkPermission)
        .alert(isPresented: $cameraModel.alert) {
            Alert(title: Text("Please Enable CameraModel Access or Microphone Access"))
        }
        .onReceive(Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()) { _ in
            if cameraModel.recordedDuration <= cameraModel.maxDuration && cameraModel.isRecording {
                cameraModel.recordedDuration += 0.01
            }
            
            if cameraModel.recordedDuration >= cameraModel.maxDuration && cameraModel.isRecording {
                cameraModel.stopRecording()
                cameraModel.isRecording = false
            }
        }
    }
}

#Preview {
    CameraTest()
}

struct CameraVideoModelPreview: UIViewRepresentable {
    @EnvironmentObject var cameraModel: CameraVideoViewModel
    var size: CGSize
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIView()
        
        DispatchQueue.main.async {
            cameraModel.preview = AVCaptureVideoPreviewLayer(session: cameraModel.session)
            cameraModel.preview.frame.size = size
            
            cameraModel.preview.videoGravity = .resizeAspectFill
            view.layer.addSublayer(cameraModel.preview)
        }
        
        DispatchQueue.global(qos: .background).async {
            cameraModel.session.startRunning()
        }
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
}
