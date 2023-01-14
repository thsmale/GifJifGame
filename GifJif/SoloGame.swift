//
//  SoloGame.swift
//  GifJif
//
//  Created by Tommy Smale on 11/7/22.
//

import SwiftUI
import GiphyUISDK

//No pick winner here
//Just a topic generator
//To look up gifs
//Displayed when one user in game
//Maybe rename to SimpleGame
struct SoloGame: View {
    @EnvironmentObject private var player_one: PlayerOne
    @Binding var game: Game
    @State private var topic: String = ""
    @State private var topic_status: Status = Status()
    @State private var show_giphy_picker = false
    @State private var giphy_media: GPHMedia? = nil
    @State private var gifs: [Gif] = []
    @State private var play_with_time = true
    @State private var play_with_topic = true
    @State private var show_times_up = false
    @State private var round_started = false
    ////
    @State private var time = 60
    @State private var timer: Timer? = nil
    @State private var show_submit_winner_fail = false
    @Environment(\.presentationMode) var presentationMode


    func start_timer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            time -= 1
            if (time <= 0) {
                end_timer()
                show_times_up = true
            }
        })
    }
    
    func end_timer() {
        timer?.invalidate()
        timer = nil
    }
    
    private var times_up: Binding<Bool> {
        Binding {
            if (time <= 0) {
                return true
            }
            return false
        } set: { bool in
            self.show_times_up = bool
            self.round_started = false
            self.show_giphy_picker = false
        }
    }
    
    
    private struct Gif: Identifiable {
        let id = UUID()
        let giphy_media: GPHMedia
        var topic: String
    }
    
    func new_round() {
        
    }
    
    //TODO: add_player or send_invitation first
    func invite_player(user: User) {
        let player = Player(doc_id: user.doc_id, username: user.username)
        //players.append(player)
        add_player(doc_id: game.doc_id, player: player) { success in
            if (success) {
                print("successfully sent invitation")
                send_invitation(user_doc_id: user.doc_id, game_doc_id: game.doc_id)
            } else {
                print("Failed to send invitation")
            }
        }
    }
    
    var body: some View {
        Form {
            Section("Game info") {
                GameInfo(game: $game)
            }
            /*
            Section("Game info") {
                FetchUser(action: invite_player)
                NavigationLink("Players") {
                    EditPlayers(players: game.players)
                }
                NavigationLink("Stats") {
                    Stats(game: game)
                }
                Button(action: {
                    player_one.leave_game(doc_id: game.doc_id, final_player: game.players.count <= 1 ? true : false)
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Leave game")
                        .foregroundColor(.red)
                }
            }
             */
            Section(header: Text("Play")) {
                Text("Topic: \(topic)")
                if (!round_started) {
                    TopicGenerator(topic: $topic)
                    Toggle(isOn: $play_with_time) {
                        Text("Timed")
                    }
                    if (play_with_time) {
                        TimePicker(time: $time)
                        Button(action: {
                            start_timer()
                            round_started = true
                            show_giphy_picker = true
                        }) {
                            Text("Start Round")
                        }.disabled(time <= 0 || topic == "")
                    } else {
                        Button("Start Round") {
                            show_giphy_picker = true
                            round_started = true
                        }.disabled(topic == "")
                    }
                } else {
                    if (play_with_time) {
                        Text("Time: \(time)")
                        if (show_times_up) {
                            Text("Times up!")
                                .foregroundColor(.red)
                        }
                        Button("Pick gif") {
                            show_giphy_picker = true
                        }.disabled(time <= 0)
                    }
                    Button("Submit") {
                        //TODO: What if user does not have an account
                        let player = Player(doc_id: player_one.user.doc_id, username: player_one.user.username)
                        let response = Response(gif_id: giphy_media?.id ?? "snail", player: player)
                        let winner = Winner(topic: topic, response: response)
                        submit_winner(doc_id: game.doc_id, winner: winner) { success in
                            if (success) {
                                game.winners.append(winner)
                                topic = ""
                                giphy_media = nil
                                round_started = false
                                time = 60
                                end_timer()
                                show_times_up = false
                            } else {
                                show_submit_winner_fail = true
                            }
                        }
                    }.disabled(topic == "")
                    if (show_times_up && giphy_media == nil) {
                        Text("You ran out of time and did not have a gif selected. This honorable snail has volunteered to represent you.")
                        Image("snail")
                            .aspectRatio(contentMode: .fit)
                            .frame(alignment: .center)
                    } else {
                        ShowMedia(media: $giphy_media)
                            .aspectRatio(contentMode: .fit)
                    }
                }
                //TODO: You should be able to select multiple gifs
            }
        }
        
        .sheet(isPresented: $show_giphy_picker, content: {
            VStack {
                Text("Topic: \(topic)")
                if (play_with_time) {
                    Text("Time: \(time) seconds")
                }
                GiphyUI(media: $giphy_media)
            }
        })
        .alert(Text("Failed to submit response"), isPresented: $show_submit_winner_fail) {
            Button("🤬") {show_submit_winner_fail = false}
            Button("🙄") {show_submit_winner_fail = false}
            Button("😭") {show_submit_winner_fail = false}
        }
        .navigationTitle(game.name)
    }
}
