//
//  CameraViewModel.swift
//  EC
//
//  Created by Justin Zhang on 1/2/24.
//

import Combine
import SwiftUI
import AVFoundation
import Photos

class CameraViewModel: NSObject,ObservableObject,AVCaptureFileOutputRecordingDelegate {
    let service = CameraService()
    
    @Published var photo: Photo?
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
    @Published var doneWithCamera: Bool = false // used for no flash capture image
    @Published var doneRecording: Bool = false // only for recording
    @Published var doneTakingFlashPhoto: Bool = false // only for flash
    @Published var doneTakingNormalPhoto: Bool = false
    @Published var mediaSaved: Bool = false
    
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
        if isFlashOn {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6, execute: {
                self.freezeCamera()
                self.doneTakingFlashPhoto.toggle()
            })
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: {
                self.freezeCamera()
                self.doneTakingNormalPhoto.toggle()
            })
        }
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
    
    func saveImageToLibaray() {
        DispatchQueue.main.async {
            if let photoData = self.photo?.originalData {
                guard let image = UIImage(data: photoData) else {return}
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                print("Image Saved")
            }
        }
    }
    
    func saveVideoToLibaray() {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: self.previewURL!)}) { saved, error in
                if saved {
                    let fetchOptions = PHFetchOptions()
                    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]

                    // After uploading we fetch the PHAsset for most recent video and then get its current location url

                    let fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions).lastObject
                    PHImageManager().requestAVAsset(forVideo: fetchResult!, options: nil, resultHandler: { (avurlAsset, audioMix, dict) in
                        let newObj = avurlAsset as! AVURLAsset
                        print("Video Saved")
//                        print(newObj.url) // This is the URL we need now to access the video from gallery directly.
                        })
                }
        }
    }
    
    func uploadToStory(type: Int) async throws{
        // 0 = photo 1 = video
        if type == 0 {
            if let photoData = self.photo?.originalData {
                guard let image = UIImage(data: photoData) else {return}
                let story = LibrayPhotos(uiImage: image)
                try await StoryService().uploadSingleProfileStory(item: story)
            }
        } else {
            if let previewURL = previewURL {
                if let thumbnailImage = getThumbnailImage(forUrl: previewURL) {
                    let story = LibrayPhotos(uiImage: thumbnailImage, imageUrl: previewURL)
                    try await StoryService().uploadSingleProfileStory(item: story)
                }
            }
        }
    }
    
    // get thumbnail image from video not used
    func getThumbnailImage(forUrl url: URL) -> UIImage? {
        let asset: AVAsset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)

        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        } catch let error {
            print(error)
        }

        return nil
    }
}

