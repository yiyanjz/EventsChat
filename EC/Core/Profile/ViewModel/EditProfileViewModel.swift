//
//  EditProfileViewModel.swift
//  EC
//
//  Created by Justin Zhang on 11/2/23.
//

import PhotosUI
import Firebase
import SwiftUI

@MainActor
class EditProfileViewModel: ObservableObject {
    @Published var fullname: String = ""
    @Published var bio: String = ""
    @Published var userName: String = ""
    @Published var link: String = ""
    @Published var gender: String = ""
    @Published var backgroundImage: Image?
    @Published var profileImage: Image?
    @Published var user: User
    @Published var selectedImage: PhotosPickerItem? {
        didSet {Task { await loadImage(fromItem: selectedImage)}}
    }
    private var uiImage: UIImage?
    
    // updated values
    @Published var selectedGender: String = ""
    @Published var selectedBackgroundImage: PhotosPickerItem? {
        didSet {Task { await loadBackgroundImage(fromItem: selectedBackgroundImage)}}
    }
    private var uiImageBackground: UIImage?

    init(user: User){
        self.user = user
        preFillData()
    }
    
    func loadImage(fromItem item: PhotosPickerItem?) async {
        guard let item = item else {return}
        
        guard let data = try? await item.loadTransferable(type: Data.self) else {return}
        guard let uiImage = UIImage(data: data) else {return}
        self.profileImage = Image(uiImage: uiImage)
        self.uiImage = uiImage
    }
    
    func loadBackgroundImage(fromItem item: PhotosPickerItem?) async {
        guard let item = item else {return}
        
        guard let data = try? await item.loadTransferable(type: Data.self) else {return}
        guard let uiImage = UIImage(data: data) else {return}
        self.backgroundImage = Image(uiImage: uiImage)
        self.uiImageBackground = uiImage
    }
    
    func updateUserData() async throws {
        var data = [String: Any]()
        
        // upload changed profile image
        if let uiImage = uiImage {
            let imageUrl = try await ImageUploader.uploadImage(image: uiImage, path: .profileImages)
            data["profileImageUrl"] = imageUrl
        }
        
        // update changed name
        if !fullname.isEmpty && user.fullname != fullname {
            data["fullname"] = fullname
        }
    
        // update change bio
        if !bio.isEmpty && user.bio != bio {
            data["bio"] = bio
        }
        
        // update change username
        if !userName.isEmpty && user.username != userName {
            data["username"] = userName
        }
        
        // update change link
        if !link.isEmpty && user.link != link {
            data["link"] = link
        }
        
        // update gender
        if !selectedGender.isEmpty && user.gender != selectedGender {
            data["gender"] = selectedGender
        }
        
        // update background Image
        if let uiImageBackground = uiImageBackground {
            let backgroundImageUrl = try await ImageUploader.uploadImage(image: uiImageBackground, path: .backgroundImages)
            data["backgroundImageUrl"] = backgroundImageUrl
        }
        
        // update firebase database
        if !data.isEmpty {
            try await Firestore.firestore().collection("users").document(user.id).updateData(data)
        }
    }
}

// prefill elements
extension EditProfileViewModel {
    private func preFillData() {
        // fullname
        if let fullname = user.fullname {
            self.fullname = fullname
        }
        // bio
        if let bio = user.bio {
            self.bio = bio
        }
        // username
        self.userName = user.username
        
        // link
        if let link = user.link {
            self.link = link
        }
        
        // gender
        if let gender = user.gender {
            self.gender = gender
        }
        
    }
}
