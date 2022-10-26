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
    @State var invitation_games: [Game] = []
    //Invitations are stored as a string of game_doc_id's
    //We listen to this array in the database
    //We fetch the Game, then load it for the user
    struct LoadInvitation: View {
        @StateObject private var game: FetchGame
        @ObservedObject var player_one: PlayerOne
        
        init (game_doc_id: String, player_one: PlayerOne) {
            _game = StateObject(wrappedValue: FetchGame(game_doc_id: game_doc_id))
            self.player_one = player_one
        }
        
        var body: some View {
            if (game.loading) {
                ProgressView()
            } else {
                if (game.game != nil) {
                    NavigationLink(destination: Invitation(game: game.game!, player_one: player_one)) {
                        Text(game.game!.name)
                    }
                }
            }
        }
            
        private class FetchGame: ObservableObject {
            @Published var game: Game? = nil
            @Published var loading = true
            
            init (game_doc_id: String) {
                let docRef = db.collection("games").document(game_doc_id)
                
                docRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        if let data = document.data() {
                            if let game = Game(game: data) {
                                self.game = game
                            }
                        } else {
                            print("data received is empty")
                        }
                    } else {
                        print("Document id \(game_doc_id) does not exist")
                    }
                    if (error != nil) {
                        print("Error \(String(describing: error))")
                    }
                    self.loading = false
                }
            }
        }
    }

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
                        if (player_one.user.invitations.isEmpty) {
                            Text("No invitations at the moment")
                        } else {
                            List(player_one.user.invitations, id: \.self) { game_doc_id in
                                LoadInvitation(game_doc_id: game_doc_id, player_one: player_one)
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
