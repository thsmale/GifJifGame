//
//  GameInfo.swift
//  GifJif
//
//  Created by Tommy Smale on 11/2/22.
//

import SwiftUI

//Displays basic information available to the user during game play
struct GameInfo: View {
    @Binding var game: Game
    @ObservedObject var player_one: PlayerOne
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        //Game settings is not mutable during game play
        Section(header: Text("Game info")) {
            Text("Host: \(game.host.username)")
            NavigationLink("Players") {
                List(game.players) { player in
                    Text(player.username)
                }
            }
            Text("Responses received: \($game.responses.count) / \($game.players.count == 1 ? 1 : $game.players.count - 1)")
            Button(action: {
                player_one.leave_game(doc_id: game.doc_id)
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("Leave game")
                    .foregroundColor(.red)
            }
        }
    }
}
