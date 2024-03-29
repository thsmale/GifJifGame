//
//  HosView.swift
//  GifJif
//
//  Created by Tommy Smale on 11/3/22.
//

import SwiftUI

//
//  PickTopic.swift
//  GifJif
//
//  Created by Tommy Smale on 11/3/22.
//

import SwiftUI

//Picking a topic is only visible to the Host
//This is a required task of the host to start the game
//TODO: vars time, deadline, and date should reflect current setting in game
struct HostView: View {
    @Binding var game: Game
    @State private var topic_status = Status()
    @State private var topic = ""
    @State private var time = 60
    @State private var start_game_fail = false
    @State private var deadline = true
    @State private var date = Date()
    
    var body: some View {
        Section(header: Text("Host settings")) {
            SetTopic(topic: $topic, topic_status: $topic_status)
            TimePicker(time: $time)
            Deadline(deadline: $deadline, date: $date)
            Button("Start round") {
                if (topic == "") {
                    topic_status.msg = "Topic cannot be empty"
                    return
                }
                
                if (topic.count >= MAX_TOPIC_LENGTH) {
                    topic_status.msg = "Topic exceeds max character length of \(MAX_TOPIC_LENGTH)"
                    return
                }
                start_round(doc_id: game.doc_id, topic: topic, time: time, deadline: deadline ? date: nil) { success in
                    if (success) {
                        game.topic = topic
                        game.time = time
                        game.responses = []
                        game.winner = nil
                    } else {
                        start_game_fail = true
                    }
                }
            }
            .onAppear {
                topic = game.topic
            }
        }
        .alert("Failed to start game", isPresented: $start_game_fail) {
            Button("🤬") {start_game_fail = false}
            Button("🙄") {start_game_fail = false}
            Button("😭") {start_game_fail = false}
        }
    }
}

