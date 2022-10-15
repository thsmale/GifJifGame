//
//  Camera.swift
//  GifJif
//
//  Created by Tommy Smale on 9/24/22.
//

import Foundation
import UIKit
import SwiftUI

struct Camera: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let image_picker = UIImagePickerController()
        image_picker.sourceType = .camera
        image_picker.delegate = context.coordinator
        return image_picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: Camera
        
        init(_ parent: Camera) {
            self.parent = parent
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.image = selectedImage
                    }
            picker.dismiss(animated: true)
        }
        
    }
}
