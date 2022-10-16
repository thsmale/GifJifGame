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
    var body: some View {
        ZStack {
                Form {
                    Text("Username: \(player_one.user.username)")
                    Text("Password: \(player_one.user.password)")
                    Text("First name: \(player_one.user.first_name)")
                    Text("Last name: \(player_one.user.last_name)")
                    Text("Email: \(player_one.user.email)")
                }
                .navigationTitle("Edit Profile")
            }
            .frame(alignment: .top)
        
    }
}
