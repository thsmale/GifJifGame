//
//  EditGame.swift
//  GifJif
//
//  Created by Tommy Smale on 10/29/22.
//

import SwiftUI

struct EditGame: View {
    @Binding var game: Game
    @ObservedObject var player_one: PlayerOne
    
    var body: some View {
        Section(header: Text("Game info")) {
            //Only the host can edit the game time and topic
            /*
            if (game.host == player_one.game.host) {
                
            }
             */
            Text("Time: \(game.time) seconds")
            Text("Host: \(game.host)")
            NavigationLink("Players") {
                List(game.players) { player in
                    Text(player.username)
                }
            }
            Text("Responses received: \($game.responses.count) / \($game.players.count)")
        }
    }
}

