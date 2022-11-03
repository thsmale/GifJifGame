//
//  ChangeUsername.swift
//  GifJif
//
//  Created by Tommy Smale on 11/3/22.
//

import SwiftUI

struct ChangeUsername: View {
    @EnvironmentObject private var player_one: PlayerOne
    @State private var username: String = ""
    @State private var username_status = Status()
    @State private var show_username_status = false
    
    //Passing it as parameter so if user changes text input while quering the database, setting username won't be affected
    func username_precheck(username: String) -> Bool {
        //Precheck before quering database
        if (username == player_one.user.username) {
            let msg = "\(username) is your current username"
            username_status.set(msg: msg, updating: false, success: false)
            return false
        }
        if (username == "") {
            let msg = "username cannot be blank"
            username_status.set(msg: msg, updating: false, success: false)
            return false
        }
        if (username.count > MAX_USERNAME_LENGTH) {
            let msg = "username cannot exceed \(MAX_USERNAME_LENGTH) characters"
            username_status.set(msg: msg, updating: false, success: false)
            return false
        }
        return true
    }
    
    var body: some View {
        Section(header: Text("Username")) {
            TextField("Username", text: $username)
                .textInputAutocapitalization(.never)
                .onSubmit {

                    Task {
                    //TODO: Disable textField when updating
                    if (username_precheck(username: username)) {
                        username_status.updating = true
                        //If username is unique, no user should be found in the database
                            if (await get_user(username: username)) != nil {
                                username_status.set(msg: "Username is taken",
                                                    updating: false,
                                                    success: false)
                                self.show_username_status = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    self.show_username_status = false
                                }
                                return
                            }
                            //Username passes all checks, update database
                            player_one.update_username(username: username) { success in
                                if (success) {
                                    username_status.set(msg: "Username successfully changed",
                                                        updating: false,
                                                        success: true)
                                } else {
                                    username_status.set(msg: "Failed to change username",
                                                        updating: false,
                                                        success: false)
                                }
                                self.show_username_status = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    self.show_username_status = false
                                }
                            }
                    } else {
                        //Failed the precheck, don't waste database query
                        self.show_username_status = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            self.show_username_status = false
                        }
                    }
                    }

                }
            if (username_status.updating) {
                ProgressView()
            }
            if (show_username_status) {
                Text(username_status.msg)
                    .foregroundColor(username_status.success ? .green : .red)
            }
        }
        .onAppear {
            username = player_one.user.username
        }
    }
}
