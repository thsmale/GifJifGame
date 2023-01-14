//
//  Respond.swift
//  GifJif
//
//  Created by Tommy Smale on 11/2/22.
//

import SwiftUI
import GiphyUISDK

//Features a button for the user to open the topic
//Allows the user to respond to the topic
//TODO: What to do when GIFY isn't responding and time is ticking
struct Respond: View {
    @Binding var game: Game
    @EnvironmentObject private var player_one: PlayerOne
    @State private var giphy_media: GPHMedia? = nil
    @State private var show_topic = false
    @State private var show_giphy_picker = false
    @State private var timer: Timer? = nil
    @State private var response_disabled = false
    @State private var show_submit_response_fail = false
    @State private var show_times_up = false
    @State private var time = 69
    @State private var deadline_timer: Timer? = nil
    
    //Submits the response to the userbase
    //Called when time is up or user presses submit button
    func submit() -> Void {
        end_timer()
        response_disabled = true
        let player = Player(doc_id: player_one.user.doc_id, username: player_one.user.username)
        let response = Response(gif_id: giphy_media != nil ? giphy_media!.id : "snail", player: player)
        submit_response(doc_id: game.doc_id, response: response) { success in
            if (success) {
                //player_one.games.filter
                print("Submission successful!!")
                game.responses.append(response)
                giphy_media = nil
                show_topic = false
            }
            else {
                //TODO: Handle if unable to submit response..
                show_submit_response_fail = true
            }
        }
    }
    
    func start_timer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            time -= 1
            if (time <= 0) {
                end_timer()
                response_disabled = true
                show_times_up = true
            }
        })
    }
    
    func end_timer() {
        timer?.invalidate()
        timer = nil
    }
    
    //TODO: Allow user to pick multiple gifs, then select one for submission
    var body: some View {
        Section(header: Text("Play")) {
            Text("Topic: \(show_topic ? game.topic : "Tap show topic to reveal")")
                .foregroundColor(show_topic ? .black : .gray)
            Text("Time: \(game.time)")
            if let deadline = game.deadline {
                Text(deadline, style: .date)
            }
            Button(show_topic ? "Pick gif" : "Show topic", action: {
                show_topic = true
                show_giphy_picker.toggle()
                start_timer()
            }).disabled(game.topic == "")
            if (show_topic) {
                Button("Submit", action: {
                    submit()
                }).disabled(game.time <= 0 || response_disabled)
            }
            if (giphy_media != nil) {
                ShowMedia(media: $giphy_media)
                    .aspectRatio(contentMode: .fit)
            }
        }
        //How the user picks a GIF
        .fullScreenCover(isPresented: $show_giphy_picker, content: {
            VStack {
                Text("Topic: \(game.topic)")
                Text("Time: \(game.time) seconds")
                if (giphy_media != nil) {
                    ShowMedia(media: $giphy_media)
                        .frame(width: 90, height: 90, alignment: .center)
                }
                GiphyUI(media: $giphy_media)
            }
        })
        .sheet(isPresented: $show_times_up, onDismiss: submit) {
            VStack {
                Text("You ran out of time and did not have a gif selected. This honorable snail has volunteered to represent you.")
                Image("snail")
                    .aspectRatio(contentMode: .fit)
                    .frame(alignment: .center)
            }
        }
        //TODO: Handle this error
        .alert(Text("Failed to submit response"), isPresented: $show_submit_response_fail) {
            Button("🤬") {}
            Button("🙄") {}
            Button("😭") {}
        }
        .onAppear {
            if let deadline = game.deadline {
                deadline_timer = Timer(fire: deadline, interval: 0.0, repeats: false) { _ in
                    show_times_up = true
                    deadline_timer?.invalidate()
                    deadline_timer = nil
                }
            }
            time = game.time
        }
    }
}
