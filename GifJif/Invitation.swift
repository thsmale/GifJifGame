//
//  Invitation.swift
//  GifJif
//
//  Created by Tommy Smale on 10/23/22.
//

import SwiftUI

//Maybe an invitation should include who sent it

struct Invitation: View {
    @State var game: Game
    @ObservedObject var player_one: PlayerOne
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @State private var err = false
    
    var body: some View {
        Form {
            Section(header: Text("Game info")) {
                Text("Game name: \(game.name)")
                NavigationLink("Players") {
                    List(game.players) {
                        Text($0.username)
                    }
                }
                Button("Accept") {
                    print("Player accepted invitation")
                    player_one.add_listener(game_doc_id: game.doc_id, completion: { success in
                        if (success) {
                            print("Successfully accepted invitation \(game)")
                            player_one.delete_invitation(game_doc_id: game.doc_id)
                            self.mode.wrappedValue.dismiss()
                        } else {
                            print("Failed to accept invitation \(game)")
                            err = true
                        }
                    })
                }
                Button("Reject") {
                    print("Player rejected invitation")
                    player_one.delete_invitation(game_doc_id: game.doc_id)
                    self.mode.wrappedValue.dismiss()
                }
            }
        }
        .navigationTitle("Invitation")
        .alert("Server failed to accept invitation", isPresented: $err) {
            Button("🤬") {err=false}
            Button("🙄") {err=false}
            Button("😭") {err=false}
        }
    }
}
