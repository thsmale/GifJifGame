//
//  ChangeName.swift
//  GifJif
//
//  Created by Tommy Smale on 11/3/22.
//

import SwiftUI

struct ChangeName: View {
    @EnvironmentObject private var player_one: PlayerOne
    
    @State private var first_name: String = ""
    @State private var first_name_status = Status()
    @State private var show_first_name_status = false
    
    @State private var last_name: String = ""
    @State private var last_name_status = Status()
    @State private var show_last_name_status = false
    
    
    var body: some View {
        Section(header: Text("Name")) {
            VStack(alignment: .leading) {
                Text("First Name")
                    .font(.caption)
                    .foregroundColor(Color(.placeholderText))
                TextField("First name", text: $first_name)
                    .onSubmit {
                        var precheck = true
                        if (player_one.user.first_name == first_name) {
                            first_name_status.set(msg: "No change in first name", updating: false, success: true)
                            precheck = false
                        }
                        
                        if (first_name.count >= MAX_USERNAME_LENGTH) {
                            first_name_status.set(msg: "Name exceeds character limit \(MAX_USERNAME_LENGTH)", updating: false, success: false)
                            precheck = false
                        }
                        if (precheck == false) {
                            self.show_first_name_status = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                self.show_first_name_status = false
                            }
                            return
                        }
                        first_name_status.updating = true
                        player_one.update_first_name(first_name: first_name) { [self] success in
                            if (success) {
                                first_name_status.set(msg: "First name successfully updated", updating: false, success: true)
                            } else {
                                first_name_status.set(msg: "Failed to change first name", updating: false, success: false)
                            }
                            self.show_first_name_status = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                self.show_first_name_status = false
                            }
                        }
                    }
                if (first_name_status.updating) {
                    ProgressView()
                }
                if (show_first_name_status) {
                    Text(first_name_status.msg)
                        .foregroundColor(first_name_status.success ? .green : .red)
                }
                Divider()
                //.padding(.top, 2)
                //.padding(.bottom, 2)
                
                Text("Last Name")
                    .font(.caption)
                    .foregroundColor(Color(.placeholderText))
                TextField("Last name", text: $last_name)
                    .onSubmit {
                        var precheck = true
                        if (player_one.user.last_name == last_name) {
                            last_name_status.set(msg: "No change in last name", updating: false, success: false)
                            precheck = false
                        }
                        if (last_name.count >= MAX_USERNAME_LENGTH) {
                            last_name_status.set(msg: "Last name character limit exceeds \(MAX_USERNAME_LENGTH)", updating: false, success: true)
                            precheck = false
                        }
                        if (precheck == false) {
                            show_last_name_status = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                self.show_last_name_status = false
                            }
                            return
                        }
                        self.last_name_status.updating = true
                        player_one.update_last_name(last_name: last_name) { [self] success in
                            if (success) {
                                last_name_status.set(msg: "Successfully updated last name", updating: false, success: true)
                            } else {
                                last_name_status.set(msg: "Failed to change last_name", updating: false, success: false)
                            }
                            show_last_name_status = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                self.show_last_name_status = false
                            }
                        }
                        
                    }
                //Spacer(minLength: 2)
                if (last_name_status.updating) {
                    ProgressView()
                }
                if (show_last_name_status) {
                    Text(last_name_status.msg)
                        .foregroundColor(last_name_status.success ? .green : .red)
                }
            }
        }
        .onAppear {
            first_name = player_one.user.first_name
            last_name = player_one.user.last_name
        }
    }
}

struct ChangeName_Previews: PreviewProvider {
    static var previews: some View {
        ChangeName()
    }
}
