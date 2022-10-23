//
//  ViewGames.swift
//  GifJif
//
//  Created by Tommy Smale on 9/26/22.
//

import SwiftUI
import FirebaseFirestore

struct Home: View {
    @ObservedObject var player_one: PlayerOne

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Text("GifJif").font(.title)
                Spacer()
                
                Form {
                    Section(header: Text("Account")) {
                        if (!player_one.user.username.isEmpty) {
                            Text("Welcome " + player_one.user.username)
                        }
                        NavigationLink(destination: Profile(player_one: player_one)) {
                            Text("Profile")
                        }
                        if(player_one.user.username.isEmpty) {
                            NavigationLink(destination: CreateAccount(player_one: player_one)) {
                                Text("Create account")
                            }
                            NavigationLink(destination: SignIn(player_one: player_one)) {
                                Text("Sign in")
                            }
                        } else {
                            Button(action: {player_one.sign_out()}) {
                                Text("Sign out")
                            }
                        }
                    }
                    
                    
                    Section(header: Text("My games")) {
                        NavigationLink(destination: CreateGame(player_one: player_one)) {
                            Text("Create Game")
                        }
                        if(player_one.games.isEmpty) {
                            Text("You are in no games. Create a game or join a live game!")
                        } else {
                            List(player_one.games) { game in
                                NavigationLink(destination: PlayGame(player_one: player_one, game: game)) {
                                    Text(game.name)
                                }
                            }
                        }
                    }
                     
                    
                    Section(header: Text("Invitations")) {
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

