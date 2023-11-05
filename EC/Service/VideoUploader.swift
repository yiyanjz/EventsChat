//
//  VideoUploader.swift
//  EC
//
//  Created by Justin Zhang on 11/4/23.
//

import UIKit
import Firebase
import FirebaseStorage

enum UploadVideoFolder {
    case postVideo
    
    var options: String {
        switch self {
        case .postVideo:
            return "/post_videos"
        }
    }
}

struct VideoUploader {
    // upload video
    static func uploadVideo(withData videoData: Data, path: UploadVideoFolder) async throws -> String? {
        let filename = NSUUID().uuidString
        let ref = Storage.storage().reference(withPath: "\(path.options)/\(filename)")
        let metadata = StorageMetadata()
        metadata.contentType = "video/quicktime"
        
        do {
            let _ = try await ref.putDataAsync(videoData, metadata: metadata)
            let url = try await ref.downloadURL()
            return url.absoluteString
        } catch {
            print("DEBUG: Failed to upload video with error \(error.localizedDescription)")
            return nil
        }
    }
}
