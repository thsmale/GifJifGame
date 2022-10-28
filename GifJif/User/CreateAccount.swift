//
//  CreateAccount.swift
//  GifJif
//
//  Created by Tommy Smale on 9/18/22.
//

import SwiftUI


struct CreateAccount: View {
    @ObservedObject var player_one: PlayerOne
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var password_confirmation: String = ""
    @State private var email: String = ""
    @State private var first_name: String = ""
    @State private var last_name: String = ""
    @State private var valid_username: Bool = false
    @State private var password_match: Bool = false
    @State private var ret: Bool = true
    //These are so username and password invalid error's don't appear before user has even entered a username or password
    @State private var username_submitted: Bool = false
    @State private var password_submitted: Bool = false
    //If fails to add to database show error to user
    @State private var show_error: Bool = false
    
    //Function to make sure add_user button is disabled when supposed to
    func valid_form_input() -> Bool {
        if(username == "" || password == "") {
            return false
        }
        if(!valid_username) {
            return false
        }
        if(password != password_confirmation) {
            return false
        }
        return true
    }
    
    var body: some View {
        NavigationView {
            Form {
                //[username, password, email, birthday, name]
                Section(header: Text("Required")) {
                    TextField("Username", text: $username)
                        .textInputAutocapitalization(.never)
                        .onSubmit {
                            username_submitted = true
                            if(username == "" || username.count >= MAX_USERNAME_LENGTH) {
                                valid_username = false
                                return
                            }
                            Task {
                                if (await get_user(username: username)) == nil {
                                    valid_username = true
                                } else {
                                    valid_username = false
                                }
                            }
                        }
                    if(!valid_username && username_submitted) {
                        Text("Username is not available")
                            .foregroundColor(Color.red)
                    }
                     
                    //TODO: Add autofill passwords and associated domains
                    SecureField("Password", text: $password)
                    SecureField("Confirm Password", text: $password_confirmation)
                        .onSubmit {
                            password_submitted = true
                            if (password != password_confirmation) {
                                password_match = false
                                return
                            }
                            password_match = true
                        }
                    if(!password_match && password_submitted) {
                        Text("Passwords do not match")
                            .foregroundColor(Color.red)
                    }
                }
                
                Section(header: Text("Optional reccomended information")) {
                    TextField("Email (To recover username/password", text: $email)
                        .textInputAutocapitalization(.never)
                    TextField("First Name (For finding players)", text: $first_name)
                    TextField("Last Name (For finding players)", text: $last_name)
                }
                
                Button(action: {
                    var user = User(
                        id: UUID(),
                        doc_id: "",
                        username: username,
                        password: password,
                        first_name: first_name,
                        last_name: last_name,
                        email: email,
                        game_doc_ids: [],
                        invitations: []
                    )
                    if(player_one.create_account(user: &user)) {
                        player_one.user_listener()
                    }else {
                        show_error = true
                    }
                }) {
                    Text("Add Account")
                        .padding()
                }
                .disabled(!valid_form_input())
                .alert("Server failed to create account", isPresented: $show_error) {
                    Button("🤬") {}
                    Button("🙄") {}
                    Button("😭") {}
                }
                
                
                .navigationTitle("Create an account")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}



