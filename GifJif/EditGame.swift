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
    @State private var username: String = ""
    @State private var add_user_status = Status()
    @State private var show_alert = false
    

    var body: some View {
        if (game.host.username == player_one.user.username) {
            HostView(game: $game)
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
                                    add_user_status.success = true
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
                    .foregroundColor(add_user_status.success ? .green : .red)
            }
            NavigationLink("Players") {
                List(game.players) { player in
                    Text(player.username)
                }
            }
            NavigationLink("Stats") {
                Stats(game: game)
            }
        }
    }

}

