//
//  PlayGame.swift
//  GifJif
//
//  Created by Tommy Smale on 9/21/22.
//

import SwiftUI
import GiphyUISDK

struct PlayGame: View {
    @State var player_one: PlayerOne
    @State var game: Game
    @State private var timer: Timer? = nil
    @State private var handpick_host: String = ""
    @State private var handpick_topic: String = ""
    @State private var winner: String = ""
    @State private var response_disabled = false
    @State private var submit_disabled = true
    @State private var status_text = "Preview..."
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
                            List(game.players) {
                                Text($0.username)
                            }
                        }
                        Text("Responses received: \(game.responses.count) / \(game.players.count-1)")
                    }
                }
              //  Spacer()
           // }
            
            VStack {
                Text(status_text)
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
                    submit_disabled = false
                    if (timer == nil) {
                        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
                            game.time = game.time - 1
                        })
                    }
                }, label: {
                    Text("Respond")
                }).disabled(response_disabled)
                .buttonBorderShape(.roundedRectangle)
                Spacer()
                Button("Submit", action: {
                    print(giphy_media!.id)
                    let response = Response(gif_id: giphy_media!.id, player: Player(doc_id: player_one.user.doc_id, username: player_one.user.username))
                    game.responses.append(response)
                    if (submit_response(game: game, response: response)) {
                        response_disabled = true
                        submit_disabled = true
                        status_text = "Submission successful!!"
                    } else {
                        status_text = "Failed to submit response 😭"
                    }
                }).disabled({
                    if(giphy_media == nil || submit_disabled == true) {
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

extension PlayGame {
    func HostView() -> some View {
        handpick_host = game.host
        handpick_topic = game.topic
        return Form {
            Section(header: Text("Host info")) {
                TextField("Host", text: $handpick_host)
                TextField("Topic", text: $handpick_topic)
                if (game.responses.count <= 0) {
                    Text("Responses received: \(game.responses.count) / \(game.players.count-1)")
                } else {
                    //Scroll View of Giphy UI
                    Picker("Responses", selection: $winner) {
                        List(game.responses) {
                            Text($0.player.username)
                        }
                    }
                }
                Button("Submit", action: {})
                Button("Start", action: {})
            }
        }
    }
}
