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
    let game: Game
    
    var body: some View {
        Section(header: Text("Responses")) {
            Text("Topic: \(game.topic)")
            Text("Responses received: \(game.responses.count) / \(game.players.count == 1 ? 1 : game.players.count - 1)")
            ForEach(game.responses) { response in
                LoadGif(gif_id: response.gif_id)
                    .aspectRatio(contentMode: .fit)
            }
        }
    }
}
