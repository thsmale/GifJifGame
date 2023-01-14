//
//  MyGames.swift
//  GifJif
//
//  Created by Tommy Smale on 11/8/22.
//

import SwiftUI

struct MyGames: View {
    @EnvironmentObject private var player_one: PlayerOne

    var body: some View {
        Section(header: Text("My games")) {
            if (player_one.user.username == "") {
                Text("Create an account to create or join games. All it takes is a username and password!")
            } else {
                NavigationLink(destination: CreateGame()) {
                    Text("Create Game")
                }
                if(player_one.games.isEmpty) {
                    Text("You are in no games. Create a game or join a live game!")
                } else {
                    ForEach(player_one.games.indices, id: \.self) { index in
                        DirectGame(game: self.$player_one.games[index])
                    }
                }
            }
        }
        
    }
}

