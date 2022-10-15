//
//  Profile.swift
//  GifJif
//
//  Created by Tommy Smale on 9/28/22.
//

import SwiftUI

//TODO: Make all of this editable
struct Profile: View {
    @ObservedObject var player: Player
    var body: some View {
        ZStack {
                Form {
                    Text("Username: \(player.user.username)")
                    Text("Password: \(player.user.password)")
                    Text("First name: \(player.user.first_name)")
                    Text("Last name: \(player.user.last_name)")
                    Text("Email: \(player.user.email)")
                }
                .navigationTitle("Edit Profile")
            }
            .frame(alignment: .top)
        
    }
}
