//
//  ShowResponses.swift
//  GifJif
//
//  Created by Tommy Smale on 11/2/22.
//

import SwiftUI

//Shows responses to the topic in a list where each cell is the gif
//Only reads the responses, does not write them
struct ShowResponses: View {
    @Binding var game: Game
    @EnvironmentObject private var player_one: PlayerOne
    @State private var player_responded = false
    
    var body: some View {
        Section(header: Text("Responses")) {
            //Only show other responses if player has responded
            if (game.responses.isEmpty) {
                Text("No responses")
            } else {
                if (game.host.username == player_one.user.username || player_responded) {
                    if (game.topic == "") {
                        Text("Topic: \(game.winner!.topic)")
                    } else {
                        Text("Topic: \(game.topic)")
                    }
                }
                Text("Responses received: \(game.responses.count) / \(game.players.count == 1 ? 1 : game.players.count - 1)")
                if (game.host.username == player_one.user.username || player_responded) {
                    ForEach(game.responses) { response in
                        LoadGif(gif_id: response.gif_id)
                            .aspectRatio(contentMode: .fit)
                    }
                }
            }
        }
        .onAppear {
            for response in game.responses {
                if (player_one.user.username == response.player.username) {
                    player_responded = true
                }
            }
        }
    }
}
