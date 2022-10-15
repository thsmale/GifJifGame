//
//  ViewGames.swift
//  GifJif
//
//  Created by Tommy Smale on 9/26/22.
//

import SwiftUI

struct Home: View {
    @StateObject var player = Player()
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Text("GifJif").font(.title)
                Spacer()
                
                Form {
                    Section(header: Text("Account")) {
                        if (!player.user.username.isEmpty) {
                            Text("Welcome " + player.user.username)
                        }
                        NavigationLink(destination: Profile(player: player)) {
                            Text("Profile")
                        }
                        if(player.user.username.isEmpty) {
                            NavigationLink(destination: CreateAccount(player: player)) {
                                Text("Create account")
                            }
                            NavigationLink(destination: SignIn()) {
                                Text("Sign in")
                            }
                        } else {
                            Button(action: {player.sign_out()}) {
                                Text("Sign out")
                            }
                        }
                    }
                    
                    Section(header: Text("My games")) {
                        NavigationLink(destination: CreateGame(player: player)) {
                            Text("Create Game")
                        }
                        if(player.games.isEmpty) {
                            Text("You are in no games. Create a game or join a live game!")
                        } else {
                            List(player.games) { game in
                                NavigationLink(destination: PlayGame(game: game/*, player: player.user*/)) {
                                    Text(game.name)
                                }
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

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
