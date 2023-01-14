//
//  ChangeEmail.swift
//  GifJif
//
//  Created by Tommy Smale on 11/3/22.
//

import SwiftUI

struct ChangeEmail: View {
    @EnvironmentObject private var player_one: PlayerOne
    @State private var email: String = ""
    @State private var email_status = Status()
    @State private var show_email_status = false
    
    var body: some View {
        Section(header: Text("Email")) {
            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .onSubmit {
                    var precheck = true
                    if (player_one.user.email == email) {
                        email_status.set(msg: "No change in email", updating: false, success: false)
                        precheck = false
                    }
                    if (email.count >= MAX_USERNAME_LENGTH) {
                        email_status.set(msg: "Email exceeded max character length of \(MAX_USERNAME_LENGTH)", updating: false, success: false)
                    }
                    if (!precheck) {
                        show_email_status = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            self.show_email_status = false
                        }
                        return
                    }
                    email_status.updating = true
                    player_one.update_email(email: email) { [self] success in
                        if (success) {
                            email_status.set(msg: "Successfully changed email", updating: false, success: true)
                        } else {
                            email_status.set(msg: "Failed to change email", updating: false, success: false)
                        }
                        show_email_status = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            self.show_email_status = false
                        }
                    }
                }
            if (email_status.updating) {
                ProgressView()
            }
            if (show_email_status) {
                Text(email_status.msg)
                    .foregroundColor(email_status.success ? .green : .red)
            }
        }
        .onAppear {
            email = player_one.user.email
        }
    }
}

