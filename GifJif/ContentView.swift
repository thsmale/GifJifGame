//
//  ContentView.swift
//  GifJif (change name so emphasis isn't only on gifs)
//
//  Created by Tommy Smale on 9/16/22.
//

import SwiftUI


struct ContentView: View {
    @State private var name: String = ""
    @State private var players: [User] = [get_user()]
    @State private var ret: Bool = true

    var body: some View {
        Form {
            TextField("Group name", text: $name)
            
            Section(header: Text("Add players")) {
                TextField("Search players", text: $name)
                List(players) {
                    Text($0.username)
                }
            }
            
            Section(header: Text("Game settings")) {
                Text("Pick a host")
                List(players) {
                    Text($0.username)
                }
                
                //Text("Select a category")
                
            }
            
            Button(action: { ret = create_game(group: name) }) {
                Text("Add data to database")
                    .padding()
            }
            .alert("Failed to create group", isPresented: Binding<Bool>(get: {!ret}, set: {ret = !$0})) {
                Button("🤬") {}
                Button("🙄") {}
                Button("😭") {}
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
