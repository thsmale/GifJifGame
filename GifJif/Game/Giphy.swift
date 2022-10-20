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

struct GiphyUI: UIViewControllerRepresentable {
    @Binding var url: URL?
    @Binding var media: GPHMedia?
    @Binding var media_view: GPHMediaView
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    //Configure a rating
    func makeUIViewController(context: Context) -> GiphyViewController {
        let api_key = ProcessInfo.processInfo.environment["giphy_api_key"]
        Giphy.configure(apiKey: api_key ?? "")
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
        media_view.media = media!
        //media_view.widthAnchor.constraint(equalTo: uiView.heightAnchor, multiplier: media!.aspectRatio).isActive = true
    }
}

struct ShowStaticMedia: UIViewRepresentable {
    var media: GPHMedia
    
    /*
    func get_media(completion: @escaping (GPHMedia?) -> ()) {
        print("Getting media for id \(gif_id)")
        GiphyCore.shared.gifByID(gif_id, completionHandler: { (response, error) in
            print("RES: \(String(describing: response))")
            print("Data: \(String(describing: response?.data))")
            if let gif_media = response?.data {
                print("BF Dispatch Queue")
                DispatchQueue.main.sync {
                    print("Media (dispatch queue): \(String(describing: gif_media))")
                    completion(gif_media)
                }
            }
            if (error != nil) {
                print("Err getting gifByID \(String(describing: error)) for \(gif_id)")
                completion(nil)
            }
        })
    }
     */
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        print("setting up giphy_media view")
        let media_view = GPHMediaView()
        media_view.media = media
        view.addSubview(media_view)
        media_view.translatesAutoresizingMaskIntoConstraints = false
        media_view.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        media_view.widthAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        media_view.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        media_view.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        media_view.contentMode = .scaleAspectFit
        /*
        get_media(completion: { media in
            if (media != nil) {
                print("setting up giphy_media view")
                let media_view = GPHMediaView()
                media_view.media = media
                view.addSubview(media_view)
                media_view.translatesAutoresizingMaskIntoConstraints = false
                media_view.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
                media_view.widthAnchor.constraint(equalTo: view.heightAnchor).isActive = true
                media_view.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
                media_view.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
                media_view.contentMode = .scaleAspectFit
            } else {
                print("ERRrrrrRRRRRRRRrrr")
                let error_image = UIImage(named: "froggy")
                let image_view = UIImageView(image: error_image)
                view.addSubview(image_view)
                image_view.contentMode = .scaleAspectFit
                image_view.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    image_view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    image_view.centerYAnchor.constraint(equalTo: view.centerYAnchor)
                ])
            }
        })
         */
        print("Returning from static makeuiview")
        /*

        if let media = get_media() {
            let media_view = GPHMediaView()
            media_view.media = media
            view.addSubview(media_view)
            media_view.translatesAutoresizingMaskIntoConstraints = false
            media_view.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
            media_view.widthAnchor.constraint(equalTo: view.heightAnchor).isActive = true
            media_view.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            media_view.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            media_view.contentMode = .scaleAspectFit
        } else {
            print("ERRrrrrRRRRRRRRrrr")
            let error_image = UIImage(named: "froggy")
            let image_view = UIImageView(image: error_image)
            view.addSubview(image_view)
            image_view.contentMode = .scaleAspectFit
            image_view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                image_view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                image_view.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
        }
         */
        /*
        GiphyCore.shared.gifByID(gif_id) { (response, error) in
            if let media = response?.data { [weak self] in
                DispatchQueue.main.sync {
                    self?.media_view.media = media
                }
                view.addSubview(media_view)
                media_view.translatesAutoresizingMaskIntoConstraints = false
                media_view.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
                media_view.widthAnchor.constraint(equalTo: view.heightAnchor).isActive = true
                media_view.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
                media_view.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
                media_view.contentMode = .scaleAspectFit
            }
            if ((error) != nil) {
                print("Err getting gifByID \(String(describing: error)) for \(gif_id)")
                let image_view = UIImageView()
                image_view.image = UIImage(named: "froggy")
                view.addSubview(image_view)
            }
        }
         */
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}
