//
//  ImageEditor.swift
//  EC
//
//  Created by Justin Zhang on 12/24/23.
//

import SwiftUI
import Mantis

struct ImageEditor: UIViewControllerRepresentable {
    typealias Coordinator = ImageEditorCoordinator
    @Binding var theImage: LibrayPhotos?
    @Binding var isShowing: Bool
    
    func makeCoordinator() -> ImageEditorCoordinator {
        return ImageEditorCoordinator(theImage: $theImage, isShowing: $isShowing)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImageEditor>) -> Mantis.CropViewController {
        let Editor = Mantis.cropViewController(image: theImage!.uiImage)
        Editor.delegate = context.coordinator
        return Editor
    }
}

class ImageEditorCoordinator: NSObject, CropViewControllerDelegate {
    @Binding var theImage: LibrayPhotos?
    @Binding var isShowing: Bool
    
    init(theImage: Binding<LibrayPhotos?>, isShowing: Binding<Bool>) {
        _theImage = theImage
        _isShowing = isShowing
    }
    
    func cropViewControllerDidCrop(_ cropViewController: Mantis.CropViewController, cropped: UIImage, transformation: Mantis.Transformation, cropInfo: Mantis.CropInfo) {
        theImage?.uiImage = cropped
        isShowing = false
    }
    
    func cropViewControllerDidFailToCrop(_ cropViewController: Mantis.CropViewController, original: UIImage) {
    }
    
    func cropViewControllerDidCancel(_ cropViewController: Mantis.CropViewController, original: UIImage) {
        isShowing = false
    }
    
    func cropViewControllerDidBeginResize(_ cropViewController: Mantis.CropViewController) {
    }
    
    func cropViewControllerDidEndResize(_ cropViewController: Mantis.CropViewController, original: UIImage, cropInfo: Mantis.CropInfo) {
    }
}
