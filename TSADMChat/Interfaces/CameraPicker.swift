//
//  CameraPicker.swift
//  TSADMChat
//
//  Created by Daniel Muñoz on 6/2/24.
//

import Foundation
import SwiftUI

struct CameraPickerView: UIViewControllerRepresentable {
    
    private var sourceType: UIImagePickerController.SourceType = .camera
    private let onImagePicked: (UIImage) -> Void
    
    @Environment(\.presentationMode) private var presentationMode
    
    public init(onImagePicked: @escaping (UIImage) -> Void) {
        self.onImagePicked = onImagePicked
    }
    
    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        
        //TODO: Test on real device since camera doesnt work on simulation
        if UIImagePickerController.isSourceTypeAvailable(self.sourceType) {
            picker.sourceType = self.sourceType
            if let mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera) {
                picker.mediaTypes = mediaTypes
            } 
//            else {
//                picker.mediaTypes = ["public.image"]
//            }
        } 
//        else {
//            picker.sourceType = .photoLibrary
//            if let mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) {
//                picker.mediaTypes = mediaTypes
//            } else {
//                picker.mediaTypes = ["public.image"]
//            }
//        }
        picker.delegate = context.coordinator
        return picker
    }
    
    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(
            onDismiss: { self.presentationMode.wrappedValue.dismiss() },
            onImagePicked: self.onImagePicked
        )
    }
    
    final public class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        
        private let onDismiss: () -> Void
        private let onImagePicked: (UIImage) -> Void
        
        init(onDismiss: @escaping () -> Void, onImagePicked: @escaping (UIImage) -> Void) {
            self.onDismiss = onDismiss
            self.onImagePicked = onImagePicked
        }
        
        public func imagePickerController(_ picker: UIImagePickerController,
                                          didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                self.onImagePicked(image)
            }
            self.onDismiss()
        }
        public func imagePickerControllerDidCancel(_: UIImagePickerController) {
            self.onDismiss()
        }
    }
}
