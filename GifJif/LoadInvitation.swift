//
//  LoadInvitation.swift
//  GifJif
//
//  Created by Tommy Smale on 11/2/22.
//

import SwiftUI

//Invitations are stored as a string of game_doc_id's
//We listen to this array in the database
//We fetch the Game, then load it for the user
struct LoadInvitation: View {
    @StateObject private var game: FetchGame
    @EnvironmentObject var player_one: PlayerOne
    
    init (game_doc_id: String) {
        _game = StateObject(wrappedValue: FetchGame(game_doc_id: game_doc_id))
    }
    
    var body: some View {
        if (game.loading) {
            ProgressView()
        } else {
            if (game.game != nil) {
                NavigationLink(destination: Invitation(game: game.game!)) {
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
                if let error = error {
                    print("FetchGame error \(error)")
                }
                if let document = document, document.exists {
                    if let data = document.data() {
                        if var game = Game(game: data) {
                            if (game.doc_id == "") {
                                game.doc_id = game_doc_id
                            }
                            self.game = game
                        }
                    } else {
                        print("FetchGame data received is empty")
                    }
                } else {
                    print("FetchGame Document id \(game_doc_id) does not exist")
                }
                self.loading = false
            }
        }
    }
}
