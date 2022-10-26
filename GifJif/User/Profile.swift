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
    @State private var username: String
    @State private var password: String
    @State private var confirm_password: String = ""
    @State private var show_confirm_password = false
    @State private var first_name: String
    @State private var last_name : String
    @State private var email: String
    
    init(player_one: PlayerOne) {
        self.player_one = player_one
        self.username = player_one.user.username
        self.password = player_one.user.password
        self.first_name = player_one.user.first_name
        self.last_name = player_one.user.last_name
        self.email = player_one.user.email
    }
    
    var body: some View {
        Form {
            Section(header: Text("Username")) {
                TextField("Username", text: $username)
                    .onSubmit {
                        
                    }
            }
            
            Section(header: Text("Password")) {
                SecureField("Password", text: $password)
                    .onChange(of: password) { _ in
                        show_confirm_password = true
                    }
                if (show_confirm_password) {
                    SecureField("Confirm new password", text: $confirm_password)
                }
                HStack {
                    Button("Show password") {
                        
                    }
                    /*
                    Button(action: {
                        
                    }) {
                        HStack {
                            Spacer()
                            Text("Show password")
                            Spacer()
                        }
                    }
                     */
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

            /*
            HStack {
                Button("Cancel") {
                    
                }
                Spacer()
                Button("Save") {
                    
                }
            }
             */
            
            /*
            Button(action: {
                
            }) {

                    Text("Save")

            }

            Button(action: {
                
            }) {
                HStack {
                    Spacer()
                    Text("Cancel")
                    Spacer()
                }

            }

            Button(action: {
        
            }) {
                HStack {
                    Spacer()
                    Text("Delete Account")
                        .foregroundColor(.red)
                    Spacer()
                }
            }
             */
        


                VStack {
                    Button(action: {
                        
                    }) {
                        HStack {
                            Spacer()
                            Text("Save")
                            Spacer()
                        }
                    }
                    .padding(.top, 2)
                    .padding(.bottom, 2)
                    //.padding(.top = 2, .bottom = 2)
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
                    .padding(.top, 2)
                    .padding(.bottom, 2)
                    //.padding(.top = 2, .bottom = 2)
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
                    .padding(.top, 2)
                    .padding(.bottom, 2)
                    //.padding(.top = 2, .bottom = 2)
                }
            
                   /*
            
            Section {
                Button(action: {
                    
                }) {
                    HStack {
                        Spacer()
                        Text("Save")
                        Spacer()
                    }
                }
                
                Button(action: {
                    
                }) {
                    HStack {
                        Spacer()
                        Text("Cancel")
                        Spacer()
                    }
                }
                Button(action: {
                    
                }) {
                    HStack {
                        Spacer()
                        Text("Delete Profile")
                            .foregroundColor(.red)
                            .frame(alignment: .center)
                        
                        Spacer()
                    }
                }
            }
            
            Section {
                Button(action: {
                    
                }) {
                        Text("Save")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .multilineTextAlignment(.center)

                    }
                Button(action: {
                    
                }) {
                        Text("Cancel")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .multilineTextAlignment(.center)

                    }
                Button(action: {
                    
                }) {
                        Text("Delete Profile")
                            .foregroundColor(.red)
                            .frame(alignment: .center)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .multilineTextAlignment(.center)

                }
            }
            
            Form {
                Button(action: {
                    
                }) {
                    HStack {
                        Spacer()
                        Text("Save")
                        Spacer()
                    }
                }
            }
            
            Form {
                
                Button(action: {
                    
                }) {
                    HStack {
                        Spacer()
                        Text("Cancel")
                        Spacer()
                    }
                }
            }
            
            Form {
                Button(action: {
                    
                }) {
                    HStack {
                        Spacer()
                        Text("Delete Profile")
                            .foregroundColor(.red)
                            .frame(alignment: .center)
                        
                        Spacer()
                    }
                }
            }

*/
     
            
        }
        
            .navigationTitle("Edit Profile")
    }
}
