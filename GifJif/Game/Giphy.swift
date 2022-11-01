//
//  Giphy.swift
//  GifJif
//
//  Created by Tommy Smale on 9/25/22.
//

import Foundation
import GiphyUISDK
import SwiftUI
import UIKit
import os

//The picker for selecting a gif
struct GiphyUI: UIViewControllerRepresentable {
    @Binding var url: URL?
    @Binding var media: GPHMedia?
    @Binding var media_view: GPHMediaView
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    //Configure a rating
    func makeUIViewController(context: Context) -> GiphyViewController {
        let giphy = GiphyViewController()
        giphy.mediaTypeConfig = [.gifs, .stickers, .text, .emoji]
        giphy.theme = GPHTheme(type: .automatic)
        giphy.delegate = context.coordinator
        return giphy
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    class Coordinator: NSObject, GiphyDelegate {
        let parent: GiphyUI
        
        init(_ parent: GiphyUI) {
            self.parent = parent
        }
        
        func didSelectMedia(giphyViewController: GiphyViewController, media: GPHMedia) {
            if let gifURL = media.url(rendition: .original, fileType: .gif) {
                parent.url = URL(string: gifURL)
            }
            parent.media = media
            parent.media_view.media = media
            giphyViewController.dismiss(animated: true)
        }
        
        func didDismiss(controller: GiphyViewController?) {
            if(controller != nil) {
                controller!.dismiss(animated: true)
            }
        }
    }
}

//A view to display the gif
struct ShowMedia: UIViewRepresentable {
    @Binding var media: GPHMedia?
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let media_view = GPHMediaView()
        view.addSubview(media_view)
        media_view.translatesAutoresizingMaskIntoConstraints = false
        media_view.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        media_view.widthAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        media_view.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        media_view.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        media_view.contentMode = .scaleAspectFit
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        let media_view = uiView.subviews[0] as! GPHMediaView
        if let media = media {
            media_view.media = media
        }
    }
}

struct ShowStaticMedia: UIViewRepresentable {
    var media: GPHMedia
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        print("setting up giphy_media view \(media)")
        let media_view = GPHMediaView()
        media_view.media = media
        view.addSubview(media_view)
        media_view.translatesAutoresizingMaskIntoConstraints = false
        media_view.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        media_view.widthAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        media_view.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        media_view.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        media_view.contentMode = .scaleAspectFit
        print("Returning from static makeuiview")
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}
