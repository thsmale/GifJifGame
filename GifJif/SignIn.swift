//
//  SignIn.swift
//  GifJif
//
//  Created by Tommy Smale on 9/27/22.
//

import SwiftUI

struct SignIn: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var valid_input: Bool = false
    @State private var valid_account: Bool = true
    @State private var loading: Bool = false
    
    var body: some View {
        VStack {
            Text("Sign in").font(.title)
            TextField("Username", text: $username)
            SecureField("Password", text: $password)
            Button("Sign in", action: {
                if(username.isEmpty && password.isEmpty) {
                    valid_input = false
                    return
                }
                valid_input = true
                Task {
                    loading = true
                    valid_account = await sign_in(username, password)
                    loading = false
                }
            })
            if(loading) {
                ProgressView()
            }
            if(valid_input) {
                if(valid_account) {
                    Text("Successfully signed in")
                        .foregroundColor(.green)
                } else {
                    Text("Invalid username or password")
                        .foregroundColor(.red)
                }
            }
        }
    }
}

struct SignIn_Previews: PreviewProvider {
    static var previews: some View {
        SignIn()
    }
}
