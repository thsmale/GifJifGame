//
//  Profile.swift
//  GifJif
//
//  Created by Tommy Smale on 9/28/22.
//

import SwiftUI

//TODO: Make all of this editable
struct Profile: View {
    @ObservedObject var player_one: PlayerOne
    
    @State private var username: String = ""
    @State private var username_status = Status()
    @State private var show_username_status = false
    
    @State private var password: String = ""
    @State private var change_password = false
    @State private var confirm_password: String = ""
    @State private var show_confirm_password = false
    @State private var password_check = ""
    @State private var show_password_check = false
    @State private var incorrect_password = false
    @State private var show_password_status = false
    @State private var password_status = Status()
    
    @State private var first_name: String
    @State private var last_name : String
    
    @State private var email: String
        
    private struct Status {
        var msg: String = ""
        var updating: Bool = false
        var success: Bool = false
        
        mutating func set(msg: String, updating: Bool, success: Bool) {
            self.msg = msg
            self.updating = updating
            self.success = success
        }
    }
    
    init(player_one: PlayerOne) {
        self.player_one = player_one
        self.username = player_one.user.username
        self.password = player_one.user.password
        self.first_name = player_one.user.first_name
        self.last_name = player_one.user.last_name
        self.email = player_one.user.email
    }
    
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
    
    //Before the user is able to change their password, they must prove it is them
    func validate_identity(password: String) {
        if (player_one.user.password == password_check) {
            change_password = true
            show_password_check = false
        } else {
            incorrect_password = true
        }
    }
    
    var body: some View {
        Form {
            Section(header: Text("Username")) {
                TextField("Username", text: $username)
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
            
            Section(header: Text("Name")) {
                VStack(alignment: .leading, spacing: 2) {
                    Spacer(minLength: 2)
                    Text("First Name")
                        .font(.caption)
                        .foregroundColor(Color(.placeholderText))
                    TextField("First name", text: $first_name)
                    Spacer(minLength: 2)
                    Divider()
                    Spacer(minLength: 2)
                    Text("Last Name")
                        .font(.caption)
                        .foregroundColor(Color(.placeholderText))
                        .frame(alignment: .leading)
                    TextField("Last name", text: $last_name)
                    Spacer(minLength: 2)
                }
            }
            
            Section(header: Text("Email")) {
                TextField("Email", text: $email)
            }


            VStack {
                Button(action: {
                    
                }) {
                    HStack {
                        Spacer()
                        Text("Save")
                        Spacer()
                    }
                }
               .padding(.top, 4)
                Divider()
                    .padding(.top, 4)
                    .padding(.bottom, 4)
                Button(action: {
                    
                }) {
                    HStack {
                        Spacer()
                        Text("Cancel")
                        Spacer()
                    }
                }
                Divider()
                    .padding(.top, 4)
                    .padding(.bottom, 4)
                Button(action: {
                    
                }) {
                    HStack {
                        Spacer()
                        Text("Delete Account")
                            .foregroundColor(.red)
                            .frame(alignment: .center)
                        Spacer()
                    }
                }
                .padding(.bottom, 4)
            }
            

            
        }
        
            .navigationTitle("Edit Profile")
        //TODO: Enter max attempts for passwords
        //Suspend user from checking for an hour
            .sheet(isPresented: $show_password_check, content: {
                Form {
                    Text("Prove it's you")
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
    }
    

}
