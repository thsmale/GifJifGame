//
//  PickTopic.swift
//  GifJif
//
//  Created by Tommy Smale on 11/4/22.
//

import SwiftUI

struct SetTopic: View {
    @Binding var topic: String
    @Binding var topic_status: Status
    private var topics: [Topic] = []
    
    private struct Topic {
        var topic: String
        let id = UUID()
    }
    
    //TODO: Put this in .onAppear or init?
    //TODO: Add movies and tvshows
    //PickTopic is called in createGame and HostView
    init(topic: Binding<String>, topic_status: Binding<Status> = .constant(Status())) {
        self._topic = topic
        self._topic_status = topic_status
        
        let filepath = Bundle.main.resourcePath! + "/red_cards.txt"
        let file_handler = FileHandle(forReadingAtPath: filepath) ?? nil
        if(file_handler == nil) {
            print("Unable to create FileHandle for red_cards.txt")
            return
        }
        do {
            let data: Data = try file_handler!.readToEnd() ?? Data()
            if(data.isEmpty == true) {
                print("red_cards.txt readToEnd() failed")
                return
            }
            let topics = String(decoding: data, as: UTF8.self)
                .split(separator: "\n")
            for topic in topics {
                self.topics.append(Topic(topic: String(topic)))
            }
        } catch {
            print("Unable to read categories.txt")
        }
    }
    
    var body: some View {
        TextField("Choose topic", text: $topic, onEditingChanged: { _ in topic_status.reset() })
        if (topic_status.msg != "") {
            Text(topic_status.msg)
                .foregroundColor(.red)
        }
        if (topics.count > 0) {
            Button("Generate topic") {
                let random_int = Int.random(in: 0..<topics.count)
                topic = topics[random_int].topic
            }
        }
    }
}
