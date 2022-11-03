//
//  ViewGames.swift
//  GifJif
//
//  Created by Tommy Smale on 9/26/22.
//

import SwiftUI
import FirebaseFirestore

struct Home: View {
    @EnvironmentObject private var player_one: PlayerOne

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Text("GifJifGame").font(.title)
                Spacer()
                                
                Form {
                    Section(header: Text("Account")) {
                        if (!player_one.user.username.isEmpty) {
                            Text("Welcome " + player_one.user.username)
                        }
                        NavigationLink(destination: Profile()) {
                            Text("Profile")
                        }
                        if(player_one.user.username.isEmpty) {
                            NavigationLink(destination: CreateAccount()) {
                                Text("Create account")
                            }
                            NavigationLink(destination: SignIn()) {
                                Text("Sign in")
                            }
                        } else {
                            Button(action: {player_one.sign_out()}) {
                                Text("Sign out")
                            }
                        }
                    }
                    
                    
                    Section(header: Text("My games")) {
                        NavigationLink(destination: CreateGame()) {
                            Text("Create Game")
                        }
                        if(player_one.games.isEmpty) {
                            Text("You are in no games. Create a game or join a live game!")
                        } else {
                            ForEach(player_one.games.indices, id: \.self) { index in
                                NavigationLink(destination: PlayGame(game: self.$player_one.games[index])) {
                                    Text(player_one.games[index].name)
                                }
                            }
                        }
                    }
                    

                    Section(header: Text("Game invitations")) {
                        if (player_one.user.invitations.isEmpty) {
                            Text("No invitations at the moment")
                        } else {
                            List(player_one.user.invitations, id: \.self) { game_doc_id in
                                LoadInvitation(game_doc_id: game_doc_id)
                            }
                        }
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
