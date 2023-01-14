//
//  EditGame.swift
//  GifJif
//
//  Created by Tommy Smale on 10/29/22.
//

import SwiftUI

struct EditGame: View {
    @Binding var game: Game
    @EnvironmentObject private var player_one: PlayerOne
    @State private var send_invitation_status = Status()
    @State private var show_invitation_status = false
    
    func show_status() {
        self.show_invitation_status = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.show_invitation_status = false
        }
    }
    
    //TODO: add_player or send_invitation first
    //TODO: Check if invitation has already been sent
    func invite_player(user: User) {
        for player in game.players {
            if (game.invitations.contains(player.doc_id)) {
                send_invitation_status.msg = "User is already in game"
                send_invitation_status.success = false
                show_status()
                return
            }
            if (player.username == user.username) {
                send_invitation_status.msg = "Resent invitation to \(user.username)"
                send_invitation_status.success = true
                send_invitation(user_doc_id: user.doc_id, game_doc_id: game.doc_id)
                show_status()
                return
            }
        }
        
        send_invitation_status.updating = true
        let player = Player(doc_id: user.doc_id, username: user.username)
        add_player(doc_id: game.doc_id, player: player) { success in
            if (success) {
                game.players.append(player)
                //TODO: Ensure you sent the invitation
                send_invitation(user_doc_id: user.doc_id, game_doc_id: game.doc_id)
                send_invitation_status.msg = "Successfully sent invitation"
                send_invitation_status.success = true
            } else {
                send_invitation_status.msg = "Failed to send invitation"
                send_invitation_status.success = false
            }
            send_invitation_status.updating = false
            show_status()
        }
    }
    
    //TODO: Change if game is public or pivate
    var body: some View {
        if (game.host.username == player_one.user.username) {
            HostView(game: $game)
        } else {
            Text("Waiting for \(game.host.username) to start next round")
        }
        Section(header: Text("Game info")) {
            FetchUser(action: invite_player)
            if (send_invitation_status.updating) {
                ProgressView()
            }
            if (show_invitation_status) {
                Text(send_invitation_status.msg)
                    .foregroundColor(send_invitation_status.success ? .green : .blue)
            }
            GameInfo(game: $game)
        }
    }
}
