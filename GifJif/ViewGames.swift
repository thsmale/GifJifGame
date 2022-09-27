//
//  ViewGames.swift
//  GifJif
//
//  Created by Tommy Smale on 9/26/22.
//

import SwiftUI

struct ViewGames: View {
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Text("GifJif").font(.title)
                Spacer()
                
                NavigationLink(destination: CreateGame()) {
                    Text("Create Game")
                }
                
                Form {
                    Section(header: Text("My games")) {
                        if(device_owner == nil) {
                            Text("Welcome! No device data was found. Sign in to retrieve data from the cloud or play without an account. Play with friends or join a live game!")
                            NavigationLink(destination: CreateAccount()) {
                                Text("Optional create account")
                            }
                            NavigationLink(destination: SignIn()) {
                                Text("Optional sign in")
                            }
                        } else {
                            List(device_owner!.games) {
                                Text($0.name)
                            }
                        }
                    }
                    
                    Section(header: Text("Public games")) {
                        Text("Comming soon!")
                    }
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
        }
         
    }
}

struct ViewGames_Previews: PreviewProvider {
    static var previews: some View {
        ViewGames()
    }
}
