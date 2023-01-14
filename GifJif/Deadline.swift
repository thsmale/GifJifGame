//
//  Deadline.swift
//  GifJif
//
//  Created by Tommy Smale on 11/11/22.
//

import SwiftUI

//This is how long all players have to respond to the prompt
//At the end of this deadline, the round will be concluded and the host will pick the best gif
struct Deadline: View {
    @Binding var deadline: Bool
    @Binding var date: Date
    
    
    var body: some View {
        Toggle("Deadline", isOn: $deadline)
        if (deadline) {
            DatePicker(
                "Deadline",
                selection: $date,
                in: Date.now...,
                displayedComponents: [.date, .hourAndMinute]
            )
        }
    }
}
