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
    @Binding var game: Game
    @State private var show_topic = false
    @State private var timer: Timer? = nil
    //Vars related to winner
    @State private var winner: Response? = nil
    @State private var show_winner = false //TODO: Show winner if next round hasn't started yet
    @State private var submit_winner_fail = false
    
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
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
            Form {
                if (game.topic == "") {
                    //Lobby (where people hang out after submitting, while waiting for others to submit, waiting for host to pick new topic)
                    //Anybody can change game info
                    //Only Host has control over game settings like category, topic, and time
                    EditGame(game: $game, player_one: player_one)
                } else {
                    //Game settings is not mutable during game play
                    Section(header: Text("Game info")) {
                        Text("Host: \(game.host.username)")
                        NavigationLink("Players") {
                            List(game.players) { player in
                                Text(player.username)
                            }
                        }
                        Text("Responses received: \($game.responses.count) / \($game.players.count)")
                        Button(action: {
                            player_one.leave_game(doc_id: game.doc_id)
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Leave game")
                                .foregroundColor(.red)
                        }
                    }
                }
                
                if (game.winner.gif_id != "") {
                    Section(header: Text("Winner")) {
                        Text("🏆🏆🐔🍽")
                        Text("\(game.winner.player.username) wins!")
                        LoadGif(gif_id: game.winner.gif_id)
                            .aspectRatio(contentMode: .fit)
                    }
                }

                if (game.host.doc_id == player_one.user.doc_id) {
                    //View for the host
                    //TODO: test that game.responess.count wont exceed number of players
                    if (game.responses.count == 0) {
                       Text("No responses yet")
                    } else if (game.responses.count < game.players.count) {
                        Section(header: Text("Responses")) {
                            if (game.responses.count == 0) {
                                Text("No responses yet")
                            }
                            if (game.responses.count == game.players.count) {
                                Text("All responses received")
                            }
                            ForEach(game.responses) { response in
                                LoadGif(gif_id: response.gif_id)
                                    .aspectRatio(contentMode: .fit)
                            }
                        }
                    } else {
                        pick_winner()
                    }
                } else {
                    //View for player
                    if (user_responded) {
                        Section(header: Text("Responses")) {
                            if (game.responses.count == 0) {
                                Text("No responses yet")
                            }
                            if (game.responses.count == game.players.count) {
                                Text("All responses received")
                            }
                            ForEach(game.responses) { response in
                                LoadGif(gif_id: response.gif_id)
                                    .aspectRatio(contentMode: .fit)
                            }
                        }
                    } else {
                        //Let the user pick their response
                        respond()
                    }
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
            .alert(Text("Failed to submit winner"), isPresented: $submit_winner_fail) {
                Button("🤬") {}
                Button("🙄") {}
                Button("😭") {}
            }
            .navigationTitle(game.name)
        }
}

extension PlayGame {
    func respond() -> some View {
        Section(header: Text("Play")) {
            Text("Topic: \(show_topic ? game.topic : "Click respond to reveal")")
                .foregroundColor(show_topic ? .black : .gray)
            Text("Time: \(game.time)")
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
            }).disabled(game.topic == "")
            if (show_topic) {
                Button("Submit", action: {
                    submit()
                }).disabled(game.time <= 0 || response_disabled)
            }
            if (giphy_media != nil) {
                ShowMedia(media: $giphy_media)
                    .aspectRatio(contentMode: .fit)
            }
        }
    }
    
    func pick_winner() -> some View {
        Section(header: Text("Pick Winner")) {
            Text("All responses received")
                ForEach(game.responses) { response in
                    VStack {
                        if (winner?.player.doc_id == response.player.doc_id) {
                            Image(systemName: "checkmark.circle.fill")
                        } else {
                            Image(systemName: "checkmark.circle")
                        }
                        LoadGif(gif_id: response.gif_id)
                            .aspectRatio(contentMode: .fit)
                            .onTapGesture {
                                winner = response
                            }
                    }
                }
            Button("Confirm winner") {
                submit_winner(doc_id: game.doc_id, winner: winner!) { success in
                    if (success) {
                        let random_int = Int.random(in: 0..<game.players.count)
                        let new_host = game.players[random_int]
                        end_round(doc_id: game.doc_id, host: new_host) { success in
                            if (!success) {
                                //TODO: Handle this better
                                submit_winner_fail = true
                            }
                        }
                    } else {
                        submit_winner_fail = true
                    }
                }
            }.disabled(winner == nil)
                
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
                Image("froggy_fail")
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
