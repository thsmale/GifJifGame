//
//  PublicGame.swift
//  GifJif
//
//  Created by Tommy Smale on 11/4/22.
//

import SwiftUI


//A view for spectating the game
//A view for playing the game
struct PublicGame: View {
    @State private var public_games: [Game] = []
    @State private var loading_public_games = false
    
    init() {
        //self._public_games = Binding<[Game]>.constant([Game]())
    }
    
    var body: some View {
        Section(header: Text("Public games")) {
            if (loading_public_games) {
                ProgressView()
            } else if (public_games.count <= 0) {
                Text("Err loading public games or no public games")
            } else {
                List($public_games) { $game in
                    Text(game.name)
                    NavigationLink(destination: PlayGame(game: $game)) {
                        Text(game.name)
                    }
                }
            }
        }
        .onAppear {
            if (public_games.count > 0) {
                return
            }
            loading_public_games = true
            print("Loading games.. does it do this every load?? cache plzz")
            get_public_games() { games in
                public_games = games
                loading_public_games = false
            }
        }
    }
}
