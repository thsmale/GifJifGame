//
//  ShowWinner.swift
//  GifJif
//
//  Created by Tommy Smale on 11/2/22.
//

import SwiftUI
import GiphyUISDK

struct ShowWinner: View {
    let winner: Winner?
    @State private var loading = true
    @State private var media: GPHMedia? = nil
    @State private var snail = false
    
    var body: some View {
        if let winner = winner {
            Section(header: Text("Winner")) {
                Text("🏆🏆🐔🍽")
                Text("\(winner.response.player.username) wins!")
                Text("Topic: \(winner.topic)")
                if (loading) {
                    ProgressView()
                } else {
                    if media != nil {
                        ShowMedia(media: $media)
                            .aspectRatio(contentMode: .fit)
                    } else if snail {
                        Image("snail")
                    } else {
                        Image("froggy_fail")
                    }
                }
            }
            .onAppear {
                loading = true
                if (winner.response.gif_id == "snail") {
                    snail = true
                    loading = false
                    return
                }
                GiphyCore.shared.gifByID(winner.response.gif_id, completionHandler: { [self] (response, error) in
                    if let error = error {
                        print("Err getting gifByID \(error) for \(winner.response.gif_id)")
                    }
                    if let media = response?.data {
                        self.media = media
                    } else {
                        self.media = nil
                    }
                    self.loading = false
                })
            }
        }
    }
}
