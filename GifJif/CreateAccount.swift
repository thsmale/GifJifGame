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
    
    var body: some View {
        NavigationView {
            Form {
                //[username, password, email, birthday, name]
                Section(header: Text("Mandatory")) {
                    TextField("Username", text: $username) 
                        .onSubmit {
                            if(username == "" || username.count > 20) {
                                valid_username = false
                                return
                            }
                            valid_username = available_username(username: username)
                        }
                    if(!valid_username) {
                        Text("Username is not available")
                            .foregroundColor(Color.red)
                    }
                     
                    SecureField("Password", text: $password)
                    SecureField("Confirm Password", text: $password_confirmation)
                        .onSubmit {
                            if (password != password_confirmation) {
                                password_match = false
                            }
                            password_match = true
                        }
                    if(!password_match) {
                        Text("Passwords do not match")
                            .foregroundColor(Color.red)
                    }
                }
                
                Section(header: Text("Optional reccomended information")) {
                    TextField("Email", text: $email)
                    TextField("First Name", text: $first_name)
                    TextField("Last Name", text: $last_name)
                }
                
                Button(action: { ret = { () -> Bool in
                    let user = User(username: username, password: password, first_name: first_name, last_name: last_name, email: email)
                    print("USER: \(user)")
                    return add_user(user: user)
                }()}) {
                    Text("Add Account")
                        .padding()
                }
                .disabled(!valid_username && !password_match)
                .alert("Server failed to create account", isPresented: Binding<Bool>(get: {!ret}, set: {ret = !$0})) {
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
