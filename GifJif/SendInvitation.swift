//
//  SendInvitation.swift
//  GifJif
//
//  Created by Tommy Smale on 11/10/22.
//

import SwiftUI

struct SendInvitation: View {
    @State private var username: String = ""
    @State private var invalid_username = false
    @State private var fetching_user = false
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("Enter username", text: $username, onEditingChanged: { _ in invalid_username = false
            })
            .onSubmit {
                fetching_user = true
                get_user(username: username) { user in
                    if let user = user {
                        invalid_username = false
                        send_invitation(user: user.doc_id, game_doc_id: game.doc_id)
                        let player = Player()
                        add_
                    } else {
                        invalid_username = true
                    }
                    fetching_user = false
                }
            }
        }
        if (fetching_user) {
            ProgressView()
        }
        if(invalid_username) {
            Text("User does not exist")
                .foregroundColor(.red)
        }
    }
}

struct SendInvitation_Previews: PreviewProvider {
    static var previews: some View {
        SendInvitation()
    }
}
