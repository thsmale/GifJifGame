//
//  EditGame.swift
//  GifJif
//
//  Created by Tommy Smale on 10/29/22.
//

import SwiftUI

struct EditGame: View {
    @Binding var game: Game
    @EnvironmentObject private var player_one: PlayerOne
    @State private var topic: String = ""
    @State private var topic_status = Status()
    @State private var username: String = ""
    @State private var add_user_status: Status = Status()
    @State private var time = 60
    @State private var show_alert = false
    @State private var start_game_fail = false
    @State private var round_started = false
    @State private var show_round_started = false

    struct Status {
        var msg: String = ""
        var updating = false
        var successs = false
        
        mutating func reset() {
            self.msg = ""
            self.updating = false
            self.successs = false
        }
    }
    
    func host_view() -> some View {
        Section(header: Text("Host settings")) {
            TextField("Choose topic", text: $topic, onEditingChanged: { _ in topic_status.reset() })
            if (topic_status.msg != "") {
                Text(topic_status.msg)
                    .foregroundColor(.red)
            }
            Picker("Time", selection: $time) {
                ForEach(0 ..< 61) {
                    Text("\($0)")
                }
            }
            Button("Start round") {
                if (topic == "") {
                    topic_status.msg = "Topic cannot be empty"
                    return
                }
                
                if (topic.count >= MAX_TOPIC_LENGTH) {
                    topic_status.msg = "Topic exceeds max character length of \(MAX_TOPIC_LENGTH)"
                    return
                }
                start_round(doc_id: game.doc_id, topic: topic, time: time) { success in
                    if (success) {
                        game.topic = topic
                        game.time = time
                        game.responses = []
                        game.winner = nil
                        round_started = true
                        show_round_started = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            self.show_round_started = false
                        }
                    } else {
                        start_game_fail = true
                    }
                }
            }.disabled(round_started)
            if (show_round_started) {
                Text("Let the game's begin!")
                    .foregroundColor(.green)
            }
        }
    }
    
    var body: some View {
        if (game.host.username == player_one.user.username) {
            host_view()
        } else {
            Text("Waiting for \(game.host.username) to start next round")
        }
        Section(header: Text("Game info")) {
            //Only the host can edit the game time and topic
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Add player via username", text: $username, onEditingChanged: { _ in add_user_status.reset()
                })
                .onSubmit {
                    add_user_status.reset()
                    if (username == "" || username.count >= MAX_USERNAME_LENGTH) {
                        add_user_status.msg = "Invalid username"
                        return
                    }
                    add_user_status.updating = true
                    Task {
                        if let user = await get_user(username: username) {
                            let player = Player(doc_id: user.doc_id, username: user.username)
                            add_player(doc_id: game.doc_id, player: player) { success in
                                if (success) {
                                    //players.append(Player(doc_id: user.doc_id, player: user))
                                    add_user_status.msg = "Successfully added user"
                                    add_user_status.successs = true
                                } else {
                                    add_user_status.msg = "Failed to add user \(username)"
                                }
                                add_user_status.updating = false
                            }
                        } else {
                            add_user_status.msg = "Username not found"
                            add_user_status.updating = false
                        }
                    }
                }
            }
            if (add_user_status.updating) {
                ProgressView()
            }
            if (add_user_status.msg != "") {
                Text(add_user_status.msg)
                    .foregroundColor(add_user_status.successs ? .green : .red)
            }
            NavigationLink("Players") {
                List(game.players) { player in
                    Text(player.username)
                }
            }
            NavigationLink("Stats") {
                
            }
        }
        /*
        .alert("Server failed to create group", isPresented: $start_game_fail) {
            Button("🤬") {$start_game_fail = false}
            Button("🙄") {$start_game_fail = false}
            Button("😭") {$start_game_fail = false}
        }
         */
    }

}

