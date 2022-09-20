//
//  ContentView.swift
//  GifJif (change name so emphasis isn't only on gifs)
//
//  Created by Tommy Smale on 9/16/22.
//

import SwiftUI

/*

struct ContentView: View {
    @State private var group_name: String = ""
    @State private var username: String = ""
    @State private var players: [User] = [get_user()]
    @State private var category: String = ""
    @State private var host_id: UUID = get_user().id
    @State private var category_id: UUID = UUID()
    @State private var ret: Bool = true

    private var categories: [Category] = read_categories()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Set a group name")) {
                    TextField("Group name", text: $group_name)
                }
                
                Section(header: Text("Add players")) {
                    TextField("Search players", text: $username)
                    //Find player in database then append to players array
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
                .navigationTitle("Create a game")
            }
        }
        
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
*/
