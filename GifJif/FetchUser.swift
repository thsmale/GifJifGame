//
//  FetchUser.swift
//  GifJif
//
//  Created by Tommy Smale on 11/10/22.
//

import SwiftUI

struct FetchUser: View {
    @State private var username: String = ""
    @State private var invalid_username = false
    @State private var status = Status()
    var action: (User) -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("Invite player via username", text: $username, onEditingChanged: { _ in
                invalid_username = false
            })
            .onSubmit {
                if (username == "" || username.count >= MAX_USERNAME_LENGTH) {
                    status.msg = "Invalid username"
                    return
                }
                status.updating = true
                get_user(username: username) { user in
                    if let user = user {
                        action(user)
                    } else {
                        status.msg = "User does not exist"
                        invalid_username = true
                    }
                    status.updating = false
                }
            }
        }
        if (status.updating) {
            ProgressView()
        }
        if(invalid_username) {
            Text(status.msg)
                .foregroundColor(.red)
        }
    }
}
