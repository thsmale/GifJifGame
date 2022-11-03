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
struct Respond: View {
    @Binding var game: Game
    @ObservedObject var player_one: PlayerOne
    @State private var giphy_media: GPHMedia? = nil
    @State private var show_topic = false
    @State private var show_giphy_picker = false
    @State private var timer: Timer? = nil
    @State private var response_disabled = false
    @State private var show_alert = false
    @State private var submit_response_fail = false
    
    //Submits the response to the userbase
    //Called when time is up or user presses submit button
    func submit() {
        timer?.invalidate()
        response_disabled = true
        if (giphy_media == nil) {
            show_alert = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                self.show_alert = false
            }
            return
        }
        let player = Player(doc_id: player_one.user.doc_id, username: player_one.user.username)
        let response = Response(gif_id: giphy_media!.id, player: player)
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
                print("Failed to submit response 😭")
            }
        }
    }
    
    //TODO: Allow user to pick multiple gifs, then select one for submission
    var body: some View {
        Section(header: Text("Play")) {
            Text("Topic: \(show_topic ? game.topic : "Click respond to reveal")")
                .foregroundColor(show_topic ? .black : .gray)
            Text("Time: \(game.time)")
            Button(show_topic ? "Pick gif" : "Show topic", action: {
                show_topic = true
                show_giphy_picker.toggle()
                if (timer == nil) {
                    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
                        game.time = game.time - 1
                        if (game.time <= 0) {
                            print("Time is up")
                            submit()
                        }
                    })
                }
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
        //TODO: How do these look as sheets??
        .alert(Text("Time's up!"), isPresented: $show_alert, actions: {
            VStack {
                //TODO add timer to this when expiring
                Text("You didn't pick anything. This snail will be submitted on your behalf")
                Image("snail")
                Button("Ok") {
                    show_alert = false
                }
                Button("Whatever") {
                    show_alert = false
                }
            }
        })
        .alert(Text("Failed to submit response"), isPresented: $submit_response_fail) {
            Button("🤬") {}
            Button("🙄") {}
            Button("😭") {}
        }
    }
}
