//
//  CreateGame.swift
//  GifJif (change name so emphasis isn't only on gifs)
//
//  Created by Tommy Smale on 9/16/22.
//

import SwiftUI

//For now force to read device_owner but in the future do not allow user to open this view if they do not have an account
//Or allow user to create game w/out account but change structure to handle that
struct CreateGame: View {
    @ObservedObject var player_one: PlayerOne
    @State private var group_name: String = ""
    @State private var username: String = ""
    @State private var players: [Player] = []
    @State private var host_id: UUID = UUID()
    @State private var topic: String = ""
    @State private var mode: String = ""
    @State private var time: Int = 60
    @State private var category: String = ""
    @State private var category_id: UUID = UUID()
    @State private var ret: Bool = true
    @State private var invalid_username = false
    
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Set a group name")) {
                    TextField("Group name", text: $group_name)
                }
                
                //TODO: search by first_name, last_name, and email
                Section(header: Text("Add players")) {
                    TextField("Enter username", text: $username, onEditingChanged: { _ in invalid_username = false
                    })
                        .onSubmit {
                            Task {
                                if let user = await get_user(username: username) {
                                    players.append(Player(doc_id: user.doc_id, username: username))
                                    invalid_username = false
                                } else {
                                    invalid_username = true
                                }
                            }
                             
                        }
                    if(invalid_username) {
                        Text("User does not exist")
                            .foregroundColor(.red)
                    }
                    List(players) {
                        Text($0.username)
                    }
                     
                }
                
                Section(header: Text("Game settings")) {
                    Picker("Pick a host", selection: $host_id) {
                        ForEach(players) {
                            Text($0.username)
                        }
                    }
                    
                    TextField("Topic", text: $topic)
                    TextField("Mode", text: $mode).disabled(true)
                    Picker("Time", selection: $time) {
                        ForEach(0 ..< 61) {
                            Text("\($0)")
                        }
                    }
                }
                
                Button(action: { ret = { () -> Bool in
                    /*
                     Throw err if required field players is empty
                     */
                    var player_usernames: [String] = []
                    var host_username: String = ""
                    for player in players {
                        player_usernames.append(player.username)
                    }
                    if let index = players.firstIndex(where: {
                        $0.id == host_id
                    }) {
                        host_username = players[index].username
                    }
                    //Save game to database
                    //Add to model
                    //TODO: Save locally
                    //Add to game_doc_id user in database
                    var game = Game(name: group_name,
                                    players: players,
                                    host: host_username,
                                    topic: topic,
                                    time: time)
                    if (create_game(game: &game)) {
                        player_one.add_listener(game_doc_id: game.doc_id)
                        if (write_games(games: player_one.games)) {
                            print("Successfully saved games locally!")
                        }
                        self.presentationMode.wrappedValue.dismiss()
                        return true
                    }
                    return false
                }()}) {
                    Text("Create Game")
                        .padding()
                }
                .alert("Server failed to create group", isPresented: Binding<Bool>(get: {!ret}, set: {ret = !$0})) {
                    Button("🤬") {}
                    Button("🙄") {}
                    Button("😭") {}
                }
                .navigationTitle("Create Game")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        
        
    }
}

