//
//  GameInfo.swift
//  GifJif
//
//  Created by Tommy Smale on 11/2/22.
//

import SwiftUI

//Displays basic information available to the user during game play
//Game settings is not mutable during game play (ex can't add player in middle of round or change topic)
struct GameInfo: View {
    @Binding var game: Game
    @EnvironmentObject private var player_one: PlayerOne
    @Environment(\.presentationMode) var presentationMode
    @State private var ingame = false
    
    var body: some View {
        Text("Host: \(game.host.username)")
        NavigationLink("Players") {
            EditPlayers(players: $game.players, invitations: $game.invitations)
        }
        NavigationLink("Stats") {
            Stats(game: game)
        }
        Text("\(game.public_game ? "Public Game" : "Private Game")")
        /*
        Button(action: {
            if ingame {
                player_one.leave_game(doc_id: game.doc_id, final_player: (game.players.count <= 1) ? true : false)
                self.presentationMode.wrappedValue.dismiss()
            } else {
                //TODO: Join the game
                print("TODO: Join the game")
            }
        }) {
            Text(ingame ? "Leave game" : "Join game")
                .foregroundColor(ingame ? .red : .blue)
        }
         */
        .onAppear {
            for player in game.players {
                if (player_one.user.username == player.username) {
                    ingame = true
                }
            }
        }
    }
}
