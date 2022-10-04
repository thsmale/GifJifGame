//
//  ViewGames.swift
//  GifJif
//
//  Created by Tommy Smale on 9/26/22.
//

import SwiftUI

struct ViewGames: View {
    @State private var handle: String = get_handle()
    @State private var games = device_owner.games
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Text("GifJif").font(.title)
                Spacer()
                
                if (handle != "") {
                    Text("Welcome \(handle)!").font(.headline)
                }
                
                NavigationLink(destination: CreateGame()) {
                    Spacer()
                    Text("Create Game")
                    Spacer()
                }
                NavigationLink(destination: Profile()) {
                    Text("Profile")
                }
                NavigationLink(destination: CreateAccount()) {
                    Text("Optional create account")
                }
                NavigationLink(destination: SignIn()) {
                    Text("Optional sign in")
                }
                
                Form {
                    Section(header: Text("My games")) {
                        if(games.isEmpty) {
                            Text("You are in no games. Create a game or join a live game! Sign in to recover your data.")
                        } else {
                            List(games) {
                                Text($0.name)
                            }
                        }
                    }
                    
                    Section(header: Text("Invintations")) {
                        Text("List game's the player has been invited to join")
                    }
                    
                    Section(header: Text("Public games")) {
                        Text("Comming soon!")
                    }
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
        }
         
    }
}

struct ViewGames_Previews: PreviewProvider {
    static var previews: some View {
        ViewGames()
    }
}
