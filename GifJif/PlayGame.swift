//
//  PlayGame.swift
//  GifJif
//
//  Created by Tommy Smale on 9/21/22.
//

import SwiftUI

struct PlayGame: View {
    @State private var topic: String = "Food"
    @State private var line: Path = Path()
    @State private var new_drag: Bool = false
    
    var body: some View {
        VStack{
            Text("Topic: \(topic)")
            Canvas { context, size in
                context.stroke(line, with: .color(.green), lineWidth: 7)
            }
            .border(Color.blue)
            .gesture(DragGesture(coordinateSpace: .local).onChanged({ value in
                if (line.isEmpty || new_drag) {
                    line.move(to: value.location)
                    new_drag = false
                } else {
                    line.addLine(to: value.location)
                }
            }).onEnded({ _ in new_drag = true }))
            
            Button("Add Gif", action: {})
            Button("Submit", action: {})
        }
    }
}

struct PlayGame_Previews: PreviewProvider {
    static var previews: some View {
        PlayGame()
    }
}
