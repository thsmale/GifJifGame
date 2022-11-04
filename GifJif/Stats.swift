//
//  Stats.swift
//  GifJif
//
//  Created by Tommy Smale on 11/4/22.
//

import SwiftUI

struct Stats: View {
    var game: Game
    private var wins: [String: Int] = [:]
    
    //Extracts win count for each player
    //Extracts total number of games played for each player
    //Add streak
    //TODO: Sort game count by games won
    init(game: Game) {
        self.game = game
        for win in game.winners {
            wins[win.response.player.username] = wins[win.response.player.username] ?? 0 + 1
        }
    }
    
    var body: some View {
        Form {
            Section(header: Text("Stats")) {
                Text("Total games played: \(game.winners.count)")
                ForEach(game.players) {
                    Text("\($0.username) wins: \(wins[$0.username] ?? 0)")
                }
            }
            if (game.winners.count > 0) {
                Section(header: Text("Winners gallery")) {
                    ForEach(game.winners) {
                        ShowWinner(winner: $0)
                    }
                }
            }
        }
    }
}
