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
    @State private var topic_status = Status()
    @State private var mode: String = ""
    @State private var time: Int = 60
    @State private var category: String = ""
    @State private var category_id: UUID = UUID()
    @State private var show_create_game_fail = false
    @State private var creating_game = false
    @State private var public_game: Bool = false
    @State private var deadline = true
    @State private var date = Date()
    @State private var invitations: [String] = []
    
    @Environment(\.presentationMode) var presentationMode
    
    
    var body: some View {
        Form {
            Section(header: Text("Name game")) {
                TextField("Game name", text: $group_name)
            }
            
            Section(header: Text("Add players")) {
                if (player_one.user.username == "") {
                    Text("Please sign in or create a username to add friends")
                    NavigationLink(destination: SignIn()) {
                        Text("Sign in")
                    }
                    NavigationLink(destination: CreateAccount()) {
                        Text("Create account")
                    }
                } else {
                    FetchUser { user in
                        let player = Player(doc_id: user.doc_id, username: user.username)
                        invitations.append(user.doc_id)
                    }
                    NavigationLink("Players") {
                        EditPlayers(players: $players, invitations: $invitations)
                    }
                }
            }
            
            Section(header: Text("Game settings")) {
                Picker("Pick a host", selection: $host_id) {
                    ForEach(players) {
                        Text($0.username)
                    }
                }
                
                SetTopic(topic: $topic, topic_status: $topic_status)
                TimePicker(time: $time)
                Deadline(deadline: $deadline, date: $date)
                Toggle("Public game", isOn: $public_game)
            }
            
            Button(action: {
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
                                deadline: deadline ? date : nil,
                                public_game: public_game,
                                invitations: invitations)
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

