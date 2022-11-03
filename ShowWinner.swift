//
//  ShowWinner.swift
//  GifJif
//
//  Created by Tommy Smale on 11/2/22.
//

import SwiftUI

struct ShowWinner: View {
    let winner: Winner?
    
    var body: some View {
        if let winner = winner {
            Section(header: Text("Winner")) {
                Text("🏆🏆🐔🍽")
                Text("\(winner.response.player.username) wins!")
                Text("Topic: \(winner.topic)")
                LoadGif(gif_id: winner.response.gif_id)
                    .aspectRatio(contentMode: .fit)
            }
        }
    }
}
