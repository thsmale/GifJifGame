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
    @State private var group_name: String = ""
    @State private var username: String = ""
    @State private var players: [User] = []
    @State private var category: String = ""
    @State private var host_id = device_owner?.id ?? UUID()
    @State private var category_id: UUID = UUID()
    @State private var ret: Bool = true
    @State private var invalid_username = false

    private var categories: [Category] = read_categories()

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
                                if let user: User = await get_user(username: username) {
                                    players.append(user)
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
                    
                    List {
                        Picker("Select category", selection: $category_id) {
                            ForEach(categories) { category in
                                Text(category.value)
                            }
                        }
                    }
                }
                
                Button(action: { ret = { () -> Bool in
                    /*
                     Throw err if required field players is empty
                     */
                    var player_usernames: [String] = []
                    var host_username: String = ""
                    var category_value: String = ""
                    for player in players {
                        player_usernames.append(player.username)
                    }
                    if let index = players.firstIndex(where: {
                        $0.id == host_id
                    }) {
                        host_username = players[index].username
                    }
                    if let index = categories.firstIndex(where: {
                        $0.id == category_id
                    })  {
                        category_value = categories[index].value
                    }
                    let game = Game(name: group_name, player_usernames: player_usernames, host: host_username, category: category_value)
                    return create_game(game: game)
                }()}) {
                    Text("Add data to database")
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

struct CreateGame_Previews: PreviewProvider {
    static var previews: some View {
        CreateGame()
    }
}

