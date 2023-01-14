//
//  EditPlayers.swift
//  GifJif
//
//  Created by Tommy Smale on 11/11/22.
//

import SwiftUI

//A view for showing the players in a game
//Also shows invitations that have been sent out
//TODO: Make players and invitations editable
struct EditPlayers: View {
    @Binding var players: [Player]
    @Binding var invitations: [String]
    @State private var invitation_players: [Player] = []
    
    var body: some View {
        List(/*selection*/) {
            Section(header: Text("Players")) {
                ForEach(players) { player in
                    Text(player.username)
                }
            }
            Section(header: Text("Invitations")) {
                if (invitations.count <= 0) {
                    Text("No outstanding invitations")
                }
                ForEach(invitation_players) { player in
                    Text(player.username)
                        .foregroundColor(.gray)
                }
            }
            .onAppear {
                //TODO: All you need is the username
                for invitation in invitations {
                    let ref = db.collection("users").document(invitation)
                    ref.getDocument { (document, error) in
                        if let error = error {
                            print("FetchGame error \(error)")
                        }
                        if let document = document, document.exists {
                            if let data = document.data() {
                                if let user = Player(player: data) {
                                    let player = Player(doc_id: invitation, username: user.username)
                                    self.invitation_players.append(player)
                                }
                            } else {
                                print("FetchGame data received is empty")
                            }
                        } else {
                            print("FetchGame Document id \(invitation) does not exist")
                        }
                    }
                }
            }
        }
    }
}
