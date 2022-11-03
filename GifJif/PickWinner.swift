//
//  PickWinner.swift
//  GifJif
//
//  Created by Tommy Smale on 11/2/22.
//

import SwiftUI

struct PickWinner: View {
    @Binding var game: Game
    @ObservedObject var player_one: PlayerOne
    @State private var winner: Winner? = nil
    @State private var submit_winner_fail = false
    
    var body: some View {
        Section(header: Text("Pick Winner")) {
            Text("All responses received")
            ForEach(game.responses) { response in
                VStack {
                    if (winner?.response.player.doc_id == response.player.doc_id) {
                        Image(systemName: "checkmark.circle.fill")
                    } else {
                        Image(systemName: "checkmark.circle")
                    }
                    LoadGif(gif_id: response.gif_id)
                        .aspectRatio(contentMode: .fit)
                }
                .onTapGesture {
                    if var winner = winner {
                        winner.response = response
                    } else {
                        winner = Winner(topic: game.topic, response: response)
                    }
                }
            }
            Button("Submit winner") {
                //TODO: Make this mutating function
                submit_winner(doc_id: game.doc_id, winner: winner!) { success in
                    if (success) {
                        //Since you will reset winner to nil in a hot sec, need to copy value of winner
                        game.winner = Winner(topic: game.topic, response: winner!.response)
                        let random_int = Int.random(in: 0..<game.players.count)
                        let new_host = game.players[random_int]
                        end_round(doc_id: game.doc_id, host: new_host) { success in
                            if (success) {
                                game.host = new_host
                                game.topic = ""
                                winner = nil
                            } else {
                                //TODO: Handle this better
                                submit_winner_fail = true
                            }
                        }
                    } else {
                        submit_winner_fail = true
                    }
                }
            }.disabled(winner == nil)
            
        }
        .alert(Text("Failed to submit winner"), isPresented: $submit_winner_fail) {
            Button("🤬") {}
            Button("🙄") {}
            Button("😭") {}
        }
    }
}
