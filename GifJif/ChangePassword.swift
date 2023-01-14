//
//  ChangePassword.swift
//  GifJif
//
//  Created by Tommy Smale on 11/3/22.
//

import SwiftUI

struct ChangePassword: View {
    @EnvironmentObject private var player_one: PlayerOne
    @State private var password: String = ""
    @State private var change_password = false
    @State private var confirm_password: String = ""
    @State private var show_confirm_password = false
    @State private var password_check = ""
    @State private var show_password_check = false
    @State private var incorrect_password = false
    @State private var show_password_status = false
    @State private var password_status = Status()
    
    //Before the user is able to change their password, they must prove it is them
    //Identity is confirmed by entering your password
    //TODO: What if user forgets password?
    func validate_identity(password: String) {
        if (player_one.user.password == password_check) {
            change_password = true
            show_password_check = false
        } else {
            incorrect_password = true
        }
    }
    
    var body: some View {
        //TODO: Add Show Password
        Section(header: Text("Password")) {
            SecureField("Password", text: $password)
                .disabled(!change_password)
            if (change_password) {
                SecureField("Confirm new password", text: $confirm_password)
                Button("Save") {
                    if (password == confirm_password) {
                        password_status.updating = true
                        player_one.update_password(password: password) { [self] success in
                            if (success) {
                                self.password_status.set(msg: "Successfully changed password",
                                                    updating: false,
                                                    success: true)
                                self.change_password = true
                            } else {
                                self.password_status.set(msg: "Failed to change username",
                                                         updating: false,
                                                         success: false)
                            }
                            self.show_password_status = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                self.show_password_status = false
                            }
                        }
                    } else {
                        //TODO: Check is passwords are different at all
                        self.password_status.set(msg: "Passwords do not match", updating: false, success: false)
                        self.password_status.msg = "Passwords do not match"
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            self.show_password_status = false
                        }
                    }
                }
                Button("Cancel") {
                    change_password = false
                }
            }
            if (password_status.updating) {
                ProgressView()
            }
            if (show_password_status) {
                Text(password_status.msg)
                    .foregroundColor(password_status.success ? .green : .red)
            }
            Button("Change password") {
                show_password_check = true
            }
        }
        //TODO: Enter max attempts for passwords
        //Suspend user from checking for an hour
            .sheet(isPresented: $show_password_check, content: {
                Form {
                    Text("Verify it's \(player_one.user.username)")
                    SecureField("Enter password", text: $password_check)
                        .onSubmit {
                            incorrect_password = false
                            validate_identity(password: password_check)
                        }
                    //TODO: animate text every time password is submitted /entered
                    if (incorrect_password) {
                        Text("Incorrect password")
                            .foregroundColor(.red)
                    }
                    Button("Enter") {
                        incorrect_password = false
                        validate_identity(password: password_check)
                    }
                    Button("Dismiss") {
                        show_password_check = false
                    }
                }
            })
            .onAppear {
                password = player_one.user.password
            }
    }

}
