//
//  Profile.swift
//  GifJif
//
//  Created by Tommy Smale on 9/28/22.
//

import SwiftUI

//TODO: Make all of this editable
struct Profile: View {
    @EnvironmentObject private var player_one: PlayerOne
    @State private var show_delete_account_confirmation = false
    @State private var delete_account_confirmation = false
    
    var body: some View {
        Form {
            ChangeUsername()
            
            ChangePassword()
            
            ChangeName()
            
            Button(action: {
                //TODO: Password protect this action
                show_delete_account_confirmation = true
                if (delete_account_confirmation) {
                    player_one.delete_account()
                }
            }) {
                HStack {
                    Spacer()
                    Text("Delete Account")
                        .foregroundColor(.red)
                        .frame(alignment: .center)
                    Spacer()
                }
            }
        }
        
        .navigationTitle("Edit Profile")
        
        .alert(Text("Confirm account deletion"), isPresented: $show_delete_account_confirmation) {
            Text("Deleting your account will remove all data locally and in the database. You will be removed from all games you are in. This cannot be undone. Are you sure?")
            Button("No") {
                show_delete_account_confirmation = false
            }
            Button("Yes") {
                delete_account_confirmation = true
                show_delete_account_confirmation = false
            }
        }
    }
}
