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
    
    var body: some View {
        TextField("Enter topic", text: $topic, onEditingChanged: { _ in topic_status.reset() })
        if (topic_status.msg != "") {
            Text(topic_status.msg)
                .foregroundColor(.red)
        }
        TopicGenerator(topic: $topic)
    }
}
