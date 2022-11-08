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
    @EnvironmentObject private var player_one: PlayerOne
    @State private var group_name: String = ""
    @State private var players: [Player] = []
    @State private var host_id: UUID = UUID()
    @State private var topic: String = ""
    @State private var mode: String = ""
    @State private var time: Int = 60
    @State private var category: String = ""
    @State private var category_id: UUID = UUID()
    @State private var show_create_game_fail = false
    @State private var creating_game = false
    @State private var public_game: Bool = false
    
    @Environment(\.presentationMode) var presentationMode
    
    
    var body: some View {
        Form {
            Section(header: Text("Set a group name")) {
                TextField("Group name", text: $group_name)
            }
            
            AddPlayers(players: $players)
            
            Section(header: Text("Game settings")) {
                Picker("Pick a host", selection: $host_id) {
                    ForEach(players) {
                        Text($0.username)
                    }
                }
                
                SetTopic(topic: $topic)
                //Public or pivate
                Picker("Time", selection: $time) {
                    ForEach(0 ..< 61) {
                        Text("\($0)")
                    }
                }
                Toggle("Public game", isOn: $public_game)
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
                                time: time,
                                public_game: public_game)
                //Save game to database
                //Add to model
                //Add to game_doc_id user in database (to recover game if local data erased)
                player_one.create_game(game: game) { doc_id in
                    creating_game = false
                    if (doc_id == nil) {
                        show_create_game_fail = true
                        return
                    }
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
        .onAppear {
            host_id = player_one.user.id
            players.append(Player(id: player_one.user.id,
                       doc_id: player_one.user.doc_id,
                       username: player_one.user.username))
        
        }
    }
    
    
}

