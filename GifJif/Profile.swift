//
//  Profile.swift
//  GifJif
//
//  Created by Tommy Smale on 9/28/22.
//

import SwiftUI

//TODO: Make all of this editable
struct Profile: View {
    var body: some View {
        Text("Username: \(device_owner.username)")
        Text("Password: \(device_owner.password)")
        Text("First name: \(device_owner.first_name)")
        Text("Last name: \(device_owner.last_name)")
        Text("Email: \(device_owner.email)")
    }
}

struct Profile_Previews: PreviewProvider {
    static var previews: some View {
        Profile()
    }
}
