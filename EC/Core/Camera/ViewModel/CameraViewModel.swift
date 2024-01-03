//
//  CameraViewModel.swift
//  EC
//
//  Created by Justin Zhang on 1/2/24.
//

import Combine
import SwiftUI
import AVFoundation

class CameraViewModel: NSObject,ObservableObject,AVCaptureFileOutputRecordingDelegate {
    let service = CameraService()
    
    @Published var photo: Photo!
    @Published var showAlertError = false
    @Published var isFlashOn = false
    @Published var willCapturePhoto = false
    var alertError: AlertError!
    @Published var session = AVCaptureSession()
    private var subscriptions = Set<AnyCancellable>()
    // video recorder properties
    @Published var isRecording: Bool = false
    @Published var recordedURLs: [URL] = []
    // preview
    @Published var previewURL: URL?
    @Published var showPreview: Bool = false
    // top progress bar
    @Published var recordedDuration: CGFloat = 0
    // your own timing
    @Published var maxDuration: CGFloat = 10
    @Published var doneWithCamera: Bool = false
    
    override init() {
        super .init()
        self.session = service.session
        
        service.$photo.sink { [weak self] (photo) in
            guard let pic = photo else { return }
            self?.photo = pic
        }
        .store(in: &self.subscriptions)
        
        service.$shouldShowAlertView.sink { [weak self] (val) in
            self?.alertError = self?.service.alertError
            self?.showAlertError = val
        }
        .store(in: &self.subscriptions)
        
        service.$flashMode.sink { [weak self] (mode) in
            self?.isFlashOn = mode == .on
        }
        .store(in: &self.subscriptions)
        
        service.$willCapturePhoto.sink { [weak self] (val) in
            self?.willCapturePhoto = val
        }
        .store(in: &self.subscriptions)
    }
    
    func configure() {
        service.checkForPermissions()
        service.configure()
    }
    
    func capturePhoto() {
        service.capturePhoto()
    }
    
    func flipCamera() {
        service.changeCamera()
    }
    
    func zoom(with factor: CGFloat) {
        service.set(zoom: factor)
    }
    
    func switchFlash() {
        service.flashMode = service.flashMode == .on ? .off : .on
    }
    
    func freezeCamera() {
        service.stop()
    }
    
    func startCamera() {
        service.start()
    }
    
    func toggleTorch(on: Bool) {
        guard
            let device = AVCaptureDevice.default(for: AVMediaType.video),
            device.hasTorch
        else { return }

        do {
            try device.lockForConfiguration()
            device.torchMode = on ? .on : .off
            device.unlockForConfiguration()
        } catch {
            print("Torch could not be used")
        }
    }
    
    // camera record
    func startRecording() {
        let tempURL = NSTemporaryDirectory() + "\(Date()).mov"
        service.audioOutput.startRecording(to: URL(fileURLWithPath: tempURL), recordingDelegate: self)
        isRecording = true
    }
    
    func stopRecording() {
        service.audioOutput.stopRecording()
        isRecording = false
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
                
        self.previewURL = outputFileURL
        self.recordedURLs.append(outputFileURL)
        if self.recordedURLs.count == 1 {
            self.previewURL = outputFileURL
            return
        }
        
        // convert urls to assets
        let assets = recordedURLs.compactMap { url -> AVURLAsset in
            return AVURLAsset(url: url)
        }
        self.previewURL = nil
        
        // merging videos
        mergeVideos(assests: assets) { exporter in
            exporter.exportAsynchronously {
                if exporter.status == .failed {
                    print(exporter.error!)
                } else {
                    if let finalURL = exporter.outputURL {
                        DispatchQueue.main.async {
                            self.previewURL = finalURL
                        }
                    }
                }
            }
        }
    }
    
    func mergeVideos(assests: [AVURLAsset], completion: @escaping (_ exporter: AVAssetExportSession)-> ()) {
        let compostion = AVMutableComposition()
        var lastTime: CMTime = .zero
        
        guard let videoTrack = compostion.addMutableTrack(withMediaType: .video, preferredTrackID: Int32(kCMPersistentTrackID_Invalid)) else {return}
        guard let audioTrack = compostion.addMutableTrack(withMediaType: .audio, preferredTrackID: Int32(kCMPersistentTrackID_Invalid)) else {return}
        
        for assest in assests {
            do {
                try videoTrack.insertTimeRange(CMTimeRange(start: .zero, duration: assest.duration), of: assest.tracks(withMediaType: .video)[0], at: lastTime)
                if !assest.tracks(withMediaType: .audio).isEmpty {
                    try audioTrack.insertTimeRange(CMTimeRange(start: .zero, duration: assest.duration), of: assest.tracks(withMediaType: .audio)[0], at: lastTime)
                }
            } catch {
                print(error.localizedDescription)
            }
            
            // updating last time
            lastTime = CMTimeAdd(lastTime, assest.duration)
        }
        
        let tempURL = URL(filePath: NSTemporaryDirectory() + "Reel-\(Date()).mp4")
        
        // video is rotated
        // bringing back to orignial transform
        let layerInstructions = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        
        // transform
        var transform = CGAffineTransform.identity
        transform = transform.rotated(by: 90 * (.pi/180))
        transform = transform.translatedBy(x: 0, y: -videoTrack.naturalSize.height)
        layerInstructions.setTransform(transform, at: .zero)
        
        let instructions = AVMutableVideoCompositionInstruction()
        instructions.timeRange = CMTimeRange(start: .zero, duration: lastTime)
        instructions.layerInstructions = [layerInstructions]
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = CGSize(width: videoTrack.naturalSize.height, height: videoTrack.naturalSize.width)
        videoComposition.instructions = [instructions]
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        
        guard let exporter = AVAssetExportSession(asset: compostion, presetName: AVAssetExportPresetHighestQuality) else {return}
        exporter.outputFileType = .mp4
        exporter.outputURL = tempURL
        exporter.videoComposition = videoComposition
        completion(exporter)
    }
    
    // thumbnail for videos
    func generateThumbnail(path: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: path, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            return thumbnail
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
}

