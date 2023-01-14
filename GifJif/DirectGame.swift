//
//  DirectGame.swift
//  GifJif
//
//  Created by Tommy Smale on 11/8/22.
//

import SwiftUI

struct DirectGame: View {
    @Binding var game: Game
    
    var body: some View {
        if (game.players.count == 1) {
            NavigationLink(destination: SoloGame(game: $game)) {
                Text(game.name)
            }
        } /*else if (game.public_game) {
            NavigationLink(destination: PublicGame()) {
                Text(game.name)
            }
        }*/ else {
            NavigationLink(destination: PlayGame(game: $game)) {
                Text(game.name)
            }
        }
    }
}
