//
//  ImageUploader.swift
//  EC
//
//  Created by Justin Zhang on 11/2/23.
//

import UIKit
import Firebase
import FirebaseStorage

enum UploadImageFolder {
    case profileImages
    case backgroundImages
    case postImages
    
    var options: String {
        switch self {
        case .profileImages:
            return "/profile_images"
        case .backgroundImages:
            return "/background_images"
        case .postImages:
            return "/post_images"
        }
    }
}

struct ImageUploader {
    // upload image
    static func uploadImage(image: UIImage, path: UploadImageFolder) async throws -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.2) else {return nil}
        let filename = NSUUID().uuidString
        let ref = Storage.storage().reference(withPath: "\(path.options)/\(filename)")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        
        do {
            let _ = try await ref.putDataAsync(imageData, metadata: metadata)
            let url = try await ref.downloadURL()
            return url.absoluteString
        } catch {
            print("DEBUG: Failed to upload image with error \(error.localizedDescription)")
            return nil
        }
    }
}
