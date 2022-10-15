//
//  PlayGame.swift
//  GifJif
//
//  Created by Tommy Smale on 9/21/22.
//

import SwiftUI
import GiphyUISDK

struct PlayGame: View {
    //@State var player: Player
    @State var game: Game
    @State private var timer: Timer? = nil
    
    //Text
    @State private var show_text_field: Bool = false
    @State private var text_input: String = ""
    //Drawing
    @State private var draw: Bool = false
    @State private var line: Path = Path()
    @State private var new_drag: Bool = false
    //Images
    @State private var show_image_picker = false
    @State private var show_camera = false
    @State private var image: UIImage?
    //Gifs
    @State private var show_giphy: Bool = false
    @State private var giphy: URL?
    @State private var giphy_media: GPHMedia? = nil
    @State private var mediaView = GPHMediaView()
    var view = UIView()
    //Safari
    @State private var safari: Bool = false
    
    @State private var valid_input: Bool = false
    @State private var preview: UIImage?
    @State private var show_preview: Bool = false
    
    
    var body: some View {
        //NavigationView {
        //Game View
        //ZStack {
        VStack {
            if (false) {
                HostView()
            }

            //VStack {
                Form {
                    Section(header: Text("Game info")) {
                        Text("Task: \(game.topic)")
                        Text("Time: \(game.time) seconds")
                        Text("Host: \(game.host)")
                        NavigationLink("Players") {
                            List(game.player_usernames, id: \.self) { username in
                                Text(username)
                            }
                        }
                    }
                }
              //  Spacer()
           // }
            
            VStack {
                Text("Preview...")
                if (giphy_media != nil) {
                    ShowMedia(mediaView: $mediaView, media: $giphy_media)
                    //.frame(alignment: .center)
                    //.frame(alignment: .top)
                }
                
                Spacer()
            }
            

            HStack (alignment: .bottom) {
                Button(action: {
                    show_giphy.toggle()
                    if (timer == nil) {
                        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
                            game.time = game.time - 1
                        })
                    }
                }, label: {
                    Text("Respond")
                })
                .buttonBorderShape(.roundedRectangle)
                Spacer()
                Button("Submit", action: {
                    //submit_response(giphy_media!.id)
                }).disabled({
                    if(giphy_media == nil) {
                        return true
                    }
                    return false
                }())
            }
            
            
            .sheet(isPresented: $show_giphy, content: {
                VStack {
                    Text("Task: \(game.topic)")
                    Text("Time: \(game.time) seconds")
                    if (giphy_media != nil) {
                        ShowMedia(mediaView: $mediaView, media: $giphy_media)
                            .frame(width: 90, height: 90, alignment: .center)
                    }
                    GiphyUI(url: $giphy, media: $giphy_media, media_view: $mediaView)
                }
            })
            .navigationTitle(game.name)
        }
    }

    
    //}
    //.frame(alignment: .top)
    
    
    
    //}
    
}

struct HostView: View {
    var body: some View {
        Text("YOLO")
    }
}
