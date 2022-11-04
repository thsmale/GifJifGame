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
    @Binding var media: GPHMedia?
    
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
            parent.media = media
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
            print("Updating media \(media.id)")
            media_view.media = media
        }
    }
}

//A view to display the gif
//TODO: Binding vs ShowStaticMedia
struct ShowStaticMedia: UIViewRepresentable {
    let media: GPHMedia
    
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
        media_view.media = media
    }
}

//For loading static responses that do not change
struct LoadGif: View {
    @StateObject private var gif: IDtoGif
    
    init (gif_id: String) {
        _gif = StateObject(wrappedValue: IDtoGif(gif_id: gif_id))
    }
    
    var body: some View {
        if (gif.loading) {
            ProgressView()
                .aspectRatio(contentMode: .fit)
        } else {
            if (gif.gif_media != nil) {
                ShowMedia(media: $gif.gif_media)
            } else {
                Image("froggy_fail")
            }
        }
    }
    
    private class IDtoGif: ObservableObject {
        @Published var gif_media: GPHMedia? = nil
        @Published var loading = true
        
        init (gif_id: String) {
            print("Getting gifByID \(gif_id)")
            GiphyCore.shared.gifByID(gif_id, completionHandler: { [self] (response, error) in
                //print("RES: \(String(describing: response))")
                //print("Data: \(String(describing: response?.data))")
                if let error = error {
                    print("Err getting gifByID \(error) for \(gif_id)")
                }
                if let media = response?.data {
                    DispatchQueue.main.sync { [weak self] in
                        self?.gif_media = media
                    }
                }
                DispatchQueue.main.sync { [weak self] in
                    self?.loading = false
                }
            })
        }
    }
}

//For loading static responses that do not change
struct LoadWinner: View {
    @Binding var game: Game
    @State var media: GPHMedia? = nil
    @State private var gif_id = ""
    
    var body: some View {
        /*
        if (gif.loading) {
            ProgressView()
                .aspectRatio(contentMode: .fit)
        } else {
            if (gif.gif_media != nil) {
                ShowWinner(game: $game)
            } else {
                Image("froggy_fail")
            }
        }
         */
        Text("WTF")
    }
    
    /*
    //@StateObject private var gif: IDtoGif = IDtoGif()
    @Binding var game: Game
    @Binding private var media: GPHMedia?
    @State private var loading = true
    
    var gif_media: Binding<GPHMedia> {
        Binding {
            if let winner = game.winner {
                return
            }
        } set: {
            
        }
    }
    
    var gif_id: Binding<String> {
        Binding {
            if let winner = game.winner {
                return winner.response.gif_id
            } else {
                return ""
            }
        } set: { gif_id in
            fetch_gif(gif_id: gif_id) { media in
                self.media = media
            }
        }
    }
    */
    
    /*
    var update: Binding<String> {
        Binding {
            self.loading = true
            fetch_gif(gif_id: gif_id) { media in
                if let media = media {
                    self.media = media
                }
                self.loading = false
            }
            return gif_id
        } set: {
            self.gif_id = $0
        }
    }
     */
    
    /*
    func fetch_gif(gif_id: String, completion: @escaping ((GPHMedia?) -> Void)) {
        print("Getting gifByID \(gif_id)")
        GiphyCore.shared.gifByID(gif_id) { (response, error) in
            if let error = error {
                print("Err getting gifByID \(error) for \(gif_id)")
                completion(nil)
            }
            if let media = response?.data {
                completion(media)
            } else {
                completion(nil)
            }
        }
    }
     */
    /*

    @State var gif_media: GPHMedia? = nil
    @State var loading = true
    @Binding var gif_id: String
    
    
    
    
    var gif_id: Binding<GPHMedia?> {
        Binding  {
            withCheckedContinuation { continuation in
                fetch_gif(gif_id: gif_id) { media in
                    continuation(returning: media)
                }
            }
        } set: { media in
            loading = true
            self.gif_media = media
        }
    }
    
    func fetch(gif_id: String) async -> GPHMedia? {
        await withCheckedContinuation { continuation in
            fetch_gif(gif_id: gif_id) { media in
                continuation.resume(returning: media)
            }
        }
    }
    
    func foo(gif_id: String, completion: @escaping ((GPHMedia?) -> Void)) {
        loading = true
        let x = GiphyCore.shared.gifByID(gif_id) { (response, error) in
            //print("RES: \(String(describing: response))")
            //print("Data: \(String(describing: response?.data))")
            loading = false
            if let error = error {
                print("Err getting gifByID \(error) for \(gif_id)")
                completion(nil)
            }
            if let media = response?.data {
                completion(media)
            } else {
                completion(nil)
            }
        }
        x.resume()
    }
    
    func fetch_gif(gif_id: String, completion: @escaping ((GPHMedia?) -> Void)) {
        print("Getting gifByID \(gif_id)")
        loading = true
        GiphyCore.shared.gifByID(gif_id) { (response, error) in
            //print("RES: \(String(describing: response))")
            //print("Data: \(String(describing: response?.data))")
            loading = false
            if let error = error {
                print("Err getting gifByID \(error) for \(gif_id)")
                completion(nil)
            }
            if let media = response?.data {
                completion(media)
            } else {
                completion(nil)
            }
        }
    }
    func fetch_gif(gif_id: String) {
        print("Getting gifByID \(gif_id)")
        loading = true
        GiphyCore.shared.gifByID(gif_id) { (response, error) in
            //print("RES: \(String(describing: response))")
            //print("Data: \(String(describing: response?.data))")
            loading = false
            if let error = error {
                print("Err getting gifByID \(error) for \(gif_id)")
            }
            if let media = response?.data {
                self.gif_media = media
            }
        }
    }
     */


    /*
    var body: some View {
        if (loading) {
            ProgressView()
                .aspectRatio(contentMode: .fit)
        } else {
            if (media != nil) {
                ShowMedia(media: $media)
            } else {
                Image("froggy_fail")
            }
        }
    }
     */
    
    /*
    func fetch_gif() {
        print("Getting gifByID \(gif_id)")
        loading = true
        GiphyCore.shared.gifByID(gif_id, completionHandler: { (response, error) in
            //print("RES: \(String(describing: response))")
            //print("Data: \(String(describing: response?.data))")
            loading = false
            if let error = error {
                print("Err getting gifByID \(error) for \(gif_id)")
                return
            }
            if let media = response?.data {
                self.gif_media = media
            }
        })
    }
     */
    
    /*
     func fetch(gif_id: String) {
         gif.fetch_gif(gif_id: gif_id)
     }
     private var IdtoGif: Binding<IDtoGif> {
           Binding {
               if let gif_id = gif_id {
                   return IDtoGif.fetch_gif(gif_id: gif_id)
               }
           }
       }
     */
    
    /*
    private class IDtoGif: ObservableObject {
        @Published var gif_media: GPHMedia? = nil
        @Published var loading = true
        
        func fetch_gif(gif_id: String) {
            print("Getting gifByID \(gif_id)")
            GiphyCore.shared.gifByID(gif_id, completionHandler: { (response, error) in
                //print("RES: \(String(describing: response))")
                //print("Data: \(String(describing: response?.data))")
                if let media = response?.data {
                    //print("BF Dispatch Queue")
                    DispatchQueue.main.sync { [weak self] in
                        print("Media (dispatch queue): \(String(describing: media))")
                        self?.gif_media = media
                    }
                }
                if let error = error {
                    print("Err getting gifByID \(error) for \(gif_id)")
                }
                DispatchQueue.main.sync { [weak self] in
                    self?.loading = false
                }
            })
        }
    }
     */
}
