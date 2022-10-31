//
//  SignIn.swift
//  GifJif
//
//  Created by Tommy Smale on 9/27/22.
//

import SwiftUI

struct SignIn: View {
    @ObservedObject var player_one: PlayerOne
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var valid_input: Bool = false
    @State private var valid_account: Bool = false
    @State private var loading: Bool = false
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    var body: some View {
            Form {
                TextField("Username", text: $username)
                    .textInputAutocapitalization(.never)
                SecureField("Password", text: $password)
                Button("Sign in", action: {
                    if(username.isEmpty && password.isEmpty) {
                        valid_input = false
                        return
                    }
                    valid_input = true
                    Task {
                        loading = true
                        player_one.sign_in(username, password) { success in
                            if (success)  {
                                print("Successfully signed in \(player_one.user)")
                                valid_account = true
                                player_one.user.save_locally()
                                player_one.load_games()
                                self.mode.wrappedValue.dismiss()
                            }
                            loading = false //TODO: Does it matter that this is here? 
                        }
                    }
                })
                if(loading) {
                    ProgressView()
                }
                if(valid_input && !loading) {
                    if(valid_account) {
                        Text("Successfully signed in")
                            .foregroundColor(.green)
                    } else {
                        Text("Invalid username or password")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Sign in")

    }
}

