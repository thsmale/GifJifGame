//
//  PlayGame.swift
//  GifJif
//
//  Created by Tommy Smale on 9/21/22.
//

import SwiftUI
import GiphyUISDK

struct PlayGame: View {
    @EnvironmentObject private var player_one: PlayerOne
    @Binding var game: Game
    //Vars related to winner
    @State private var winner: Winner? = nil
    @State private var submit_winner_fail = false
    
    @State private var response_disabled = false
    @State private var submit_disabled = true
    @State private var user_responded = false
    @State private var show_alert = false
    
    @State private var valid_input: Bool = false
    @State private var preview: UIImage?
    @State private var show_preview: Bool = false
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Form {
            //game.topic == "" implies no game is currently active
            if (game.topic == "") {
                //Lobby (where people hang out after submitting, while waiting for others to submit, waiting for host to pick new topic)
                //Anybody can change game info
                //Only Host has control over game settings like category, topic, and time
                EditGame(game: $game)
            } else {
                GameInfo(game: $game)
            }
            
            ShowWinner(winner: game.winner)
            
            if (game.host.doc_id == player_one.user.doc_id) {
                //View for the host
                //TODO: test that game.responess.count wont exceed number of players
                //TODO: make it more apparent that it's time for the host to pick the winner
                if (game.responses.count < game.players.count-1 ||
                    (game.players.count == 1 && game.responses.count < 1) ||
                    game.winner != nil) {
                    ShowResponses(game: game)
                } else {
                    PickWinner(game: $game)
                }
            } else {
                //View for player
                if (game.winner != nil) {
                    //In between games
                    ShowResponses(game: game)
                } else if game.responses.firstIndex(where: {$0.player.doc_id == player_one.user.doc_id}) == nil {
                    //The user has yet to respond
                    Respond(game: $game)
                } else {
                    //The user has responded so show them other people's responses
                    ShowResponses(game: game)
                }
            }
        }

        .navigationTitle(game.name)
    }
}
