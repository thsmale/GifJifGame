//
//  AddPlayers.swift
//  GifJif
//
//  Created by Tommy Smale on 11/7/22.
//

import SwiftUI

struct AddPlayers: View {
    @Binding var players: [Player]
    @State private var username: String = ""
    @State private var invalid_username = false
    @State private var fetching_user = false
    @State private var solo: Bool = false
    let bots: [Bot] = [Bot(name: "Robo"),
                       Bot(name: "Todd"),
                       Bot(name: "Botty mc bott bott")]
    @State private var bot_id = UUID()

    var body: some View {
        //TODO: search by first_name, last_name, and email
        Section(header: Text("Add players")) {
            Toggle(isOn: $solo) {
                Text("Solo game")
            }
            if (!solo) {
                /*
                Picker("Bots", selection: $bot_id) {
                    ForEach(bots) {
                        Text($0.name)
                    }
                }
                //TODO: This won't preserve selected bot
                .onAppear {
                    bot_id = bots[0].id
                }
                 */
                HStack {
                    Image(systemName: "magnifyingglass")
                    TextField("Enter username", text: $username, onEditingChanged: { _ in invalid_username = false
                    })
                    .onSubmit {
                        fetching_user = true
                        Task {
                            if let user = await get_user(username: username) {
                                players.append(Player(doc_id: user.doc_id, username: user.username))
                                invalid_username = false
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
            List(players) {
                Text($0.username)
            }
        }
    }
}
