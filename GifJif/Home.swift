//
//  ViewGames.swift
//  GifJif
//
//  Created by Tommy Smale on 9/26/22.
//

import SwiftUI
import FirebaseFirestore

struct Home: View {
    @StateObject var player_one = PlayerOne()
    @State var invintations_ref: DocumentReference? = nil
    
    init() {
        if (player_one.user.doc_id != "") {
            invintations_ref = db.collection("users").document(player_one.user.doc_id)
            invintations_ref?.addSnapshotListener { documentSnapshot, error in
                    guard let document = documentSnapshot else {
                        print("Error fetching document \(String(describing: error))")
                        return
                    }
                    guard let data = document.data() else {
                        print("Document data was empty")
                        return
                    }
                    print("Data: \(data)")
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
