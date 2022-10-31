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
    @State private var players: [Player]
    @State private var host_id: UUID
    @State private var topic: String = ""
    @State private var mode: String = ""
    @State private var time: Int = 60
    @State private var category: String = ""
    @State private var category_id: UUID = UUID()
    @State private var show_create_game_fail = false
    @State private var creating_game = false
    @State private var invalid_username = false
    @State private var fetching_user = false
    
    @Environment(\.presentationMode) var presentationMode
    
    init(player_one: PlayerOne) {
        self.player_one = player_one
        _host_id = State(initialValue: player_one.user.id)
        _players = State(initialValue: [(
            Player(id: player_one.user.id,
                   doc_id: player_one.user.doc_id,
                   username: player_one.user.username)
        )])
    }
    
    var body: some View {
        Form {
            Section(header: Text("Set a group name")) {
                TextField("Group name", text: $group_name)
            }
            
            //TODO: search by first_name, last_name, and email
            Section(header: Text("Add players")) {
                HStack {
                    Image(systemName: "magnifyingglass")
                    TextField("Enter username", text: $username, onEditingChanged: { _ in invalid_username = false
                    })
                    .onSubmit {
                        fetching_user = true
                        Task {
                            if let user = await get_user(username: username) {
                                players.append(Player(doc_id: user.doc_id, username: username))
                                invalid_username = false
                            } else {
                                invalid_username = true
                            }
                            fetching_user = false
                        }
                    }
                }
                if (fetching_user) {
                    ProgressView()
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
            
            Button(action: {
                /*
                 Throw err if required field players is empty
                 TODO: Host should not be a string
                 */
                creating_game = true
                var host: Player
                if let index = players.firstIndex(where: {
                    $0.id == host_id
                }) {
                    host = players[index]
                } else {
                    host = players[0]
                }
                var game = Game(name: group_name,
                                players: players,
                                host: host,
                                topic: topic,
                                time: time)
                //Save game to database
                //Add to model
                //Add to game_doc_id user in database (to recover game if local data erased)
                create_game(game: game, player_one_doc_id: player_one.user.doc_id) { doc_id in
                    creating_game = false
                    if (doc_id == nil) {
                        show_create_game_fail = true
                        return
                    }
                    game.doc_id = doc_id!
                    player_one.add_game_doc_id(game_doc_id: doc_id!) { success in
                        if (success) {
                            player_one.user.save_locally()
                        }
                        //TODO: handle error here
                    }
                    player_one.game_listener(game_doc_id: doc_id!)
                    self.presentationMode.wrappedValue.dismiss()
                }
            }) {
                Text("Create Game")
                    .padding()
            }
            //Kinda not necessary since we will go to home screen once game is created
            if (creating_game) {
                ProgressView()
            }
        }
        .alert("Server failed to create group", isPresented: $show_create_game_fail) {
            Button("🤬") {show_create_game_fail = false}
            Button("🙄") {show_create_game_fail = false}
            Button("😭") {show_create_game_fail = false}
        }
        .navigationTitle("Create Game")
    }
    
    
}

