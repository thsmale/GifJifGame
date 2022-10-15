//
//  ImagePicker.swift
//  GifJif
//
//  Created by Tommy Smale on 9/23/22.
//

import Foundation
import SwiftUI
import UIKit
import PhotosUI

//TODO: Add support for videos and multiple images
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = PHPickerFilter.images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            if(results.isEmpty) {
                //Means the user hit the close button
                picker.dismiss(animated: true)
                return
            }
            //ItemProvider conveys data or file shared between processes during drag and drop activity
            let item_provider = results[0].itemProvider
            if (item_provider.canLoadObject(ofClass: UIImage.self)) {
                item_provider.loadObject(ofClass: UIImage.self) { image, _ in
                    self.parent.image = image as? UIImage
                }
            }
            
            picker.dismiss(animated: true)
            //print("assetIdentifier: \(results[0].assetIdentifier!)")
        }
        
    }
}
