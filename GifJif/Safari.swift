//
//  Safari.swift
//  GifJif
//
//  Created by Tommy Smale on 9/24/22.
//

import Foundation
import SwiftUI
import UIKit
import SafariServices

struct Safari: UIViewControllerRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let url: URL? = URL(string: "https://www.google.com")
        if(url == nil) {
            print("Failed to create url \(String(describing: url))")
        }
        let safari_controller = SFSafariViewController(url: url!)
        safari_controller.delegate = context.coordinator
        return safari_controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    class Coordinator: NSObject, SFSafariViewControllerDelegate {
        let parent: Safari
        
        init(_ parent: Safari) {
            self.parent = parent
        }
        
        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            controller.dismiss(animated: true)
        }
    }
}
