//
//  CreateAccount.swift
//  GifJif
//
//  Created by Tommy Smale on 9/18/22.
//

import SwiftUI

struct CreateAccount: View {
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
                        .onSubmit {
                            username_submitted = true
                            if(username == "" || username.count > 20) {
                                valid_username = false
                                return
                            }
                            valid_username = available_username(username: username)
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
                    TextField("Email", text: $email)
                    TextField("First Name", text: $first_name)
                    TextField("Last Name", text: $last_name)
                }
                
                Button(action: {
                    var dict: [String: String] = [
                            "username": username,
                            "password": password,
                            "first_name": first_name,
                            "last_name": last_name,
                            "email": email
                        ]
                    if(add_user(user_data: &dict)) {
                        //read_user_file()
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
            }
        }
    }
}



struct CreateAccount_Previews: PreviewProvider {
    static var previews: some View {
        CreateAccount()
    }
}
