//
//  PlayGame.swift
//  GifJif
//
//  Created by Tommy Smale on 9/21/22.
//

import SwiftUI
import GiphyUISDK

struct PlayGame: View {
    @ObservedObject var player_one: PlayerOne
    @State var game: Game
    @State private var show_topic = false
    @State private var timer: Timer? = nil
    @State private var handpick_host: String = ""
    @State private var handpick_topic: String = ""
    @State private var winner: String = ""
    @State private var response_disabled = false
    @State private var submit_disabled = true
    @State private var user_responded = false
    @State private var show_alert = false
    //Gifs
    @State private var show_giphy: Bool = false
    @State private var giphy: URL?
    @State private var giphy_media: GPHMedia? = nil
    @State private var mediaView = GPHMediaView()
    var view = UIView()
    @State private var gif_responses: [GPHMedia?] = []
    
    @State private var valid_input: Bool = false
    @State private var preview: UIImage?
    @State private var show_preview: Bool = false
    
    
    var body: some View {
        VStack {
            if (false) {
                HostView() //Lobby (where people hang out after submitting, while waiting for others to submit, waiting for host to pick new topic)
            }

            Form {
                //Anybody can change game info
                //Host has control over game settings like category, topic, and time
                //Game settings is not mutable during game play
                //TODO: Edit game settings
                Section(header: Text("Game info")) {
                    Text("Time: \(game.time) seconds")
                    Text("Host: \(game.host)")
                    NavigationLink("Players") {
                        List(game.players) {
                            Text($0.username)
                        }
                    }
                    Text("Responses received: \(game.responses.count) / \(game.players.count)")
                }
                
                if (user_responded) {
                    //Show all the respones
                    //Show users response first
                    Section(header: Text("Responses")) {
                        Text("Responses")
                        VStack {
                            ForEach(game.responses) { response in
                                //TODO: Show user as well
                                LoadGif(gif_id: response.gif_id)
                                    .aspectRatio(contentMode: .fit)
                                
                            }
                        }
                    }
                } else {
                    //Let the user pick their response
                    respond()
                }
                
            }
            
            //How the user picks a GIF
            .sheet(isPresented: $show_giphy, content: {
                VStack {
                    Text("Task: \(game.topic)")
                    Text("Time: \(game.time) seconds")
                    if (giphy_media != nil) {
                        ShowMedia(media: $giphy_media)
                            .frame(width: 90, height: 90, alignment: .center)
                    }
                    GiphyUI(url: $giphy, media: $giphy_media, media_view: $mediaView)
                }
            })
            .alert(Text("Time's up!"), isPresented: $show_alert, actions: {
                VStack {
                    //TODO add timer to this when expiring
                    Text("You didn't pick anything. This snail will be submitted on your behalf")
                    Image("snail")
                    Button("Ok") {
                        show_alert = false
                    }
                    Button("Whatever") {
                        show_alert = false
                    }
                }
            })
            .navigationTitle(game.name)
        }
    }
    
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
                    Text("Responses received: \(game.responses.count) / \(game.players.count)")
                } else {
                    //Scroll View of Giphy UI
                    Picker("Responses", selection: $winner) {
                        List(game.responses) {
                            Text($0.player.username)
                        }
                    }
                }
                Button("Delete Game", action: {})
                Button("Submit", action: {})
                Button("Start", action: {})
            }
        }
    }
    
    func respond() -> some View {
        Section(header: Text("Play")) {
            Text("Topic: \(show_topic ? game.topic : "Click respond to reveal")")
                .foregroundColor(show_topic ? .black : .gray)
            HStack {
                Button(show_topic ? "Pick gif" : "Show topic", action: {
                    show_topic = true
                    show_giphy.toggle()
                    if (timer == nil) {
                        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
                            game.time = game.time - 1
                            if (game.time <= 0) {
                                print("Time is up")
                                submit()
                            }
                        })
                    }
                })
                Spacer()
                Button("Submit", action: {
                    submit()
                }).disabled({
                    if(show_topic == false || game.time <= 0) {
                        return true
                    }
                    return false
                }())
            }
            if (show_topic) {
                Text("Preview...")
            }
            if (giphy_media != nil) {
                ShowMedia(media: $giphy_media)
                    .aspectRatio(contentMode: .fit)
            }
        }
    }
    
    //Submits the response to the userbase
    //Called when time is up or user presses submit button
    func submit() {
        timer?.invalidate()
        response_disabled = true
        if (giphy_media == nil) {
            show_alert = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                self.show_alert = false
            }
            user_responded = true
            return
        }
        let player = Player(doc_id: player_one.user.doc_id, username: player_one.user.username)
        let response = Response(gif_id: giphy_media!.id, player: player)
        submit_response(doc_id: game.doc_id, response: response) { success in
            if (success) {
                //player_one.games.filter
                game.responses.append(response)
                print("Submission successful!!")
            }
            else {
                //TODO: Handle if unable to submit response..
                print("Failed to submit response 😭")
            }
            user_responded = true
        }
    }
}

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
                ShowStaticMedia(media: gif.gif_media!)
            } else {
                Image("froggy")
            }
        }
    }
    
    private class IDtoGif: ObservableObject {
        @Published var gif_media: GPHMedia? = nil
        @Published var loading = true
        
        init (gif_id: String) {
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
                if (error != nil) {
                    print("Err getting gifByID \(String(describing: error)) for \(gif_id)")
                }
                DispatchQueue.main.sync { [weak self] in
                    self?.loading = false
                }
            })
        }
    }
}
