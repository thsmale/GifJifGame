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
    @State private var show_text_field: Bool = false
    @State private var prompt: String = ""
    @State private var gif_search: String = ""
    @State private var text_input: String = ""
    @State private var gif: Bool = true
    
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
            
            HStack {
                Button("Gif", action: {
                    gif.toggle()
                })
                Button("Text", action: {
                    show_text_field = true
                    prompt = "Type a response"
                    gif = false
                })
                Button("Safari", action: {})
                Button("Photos", action: {})
                Button("Camera", action: {})
            }
            
            //Make a new struct for this code, pass in prompt as initiailzer
            if(gif) {
                GifSearch()
                /*
                HStack {
                    Image(systemName: "magnifyingglass")
                    TextField(prompt, text: gif ? $gif_search : $text_input)
                        .onSubmit {
                            if(gif) {
                                print("Search API \(gif_search)")
                            } else {
                                print("Add text to canvas \(text_input)")
                            }
                        }
                 
                }*/
            }
            
            Button("Submit", action: {})
        }
    }
}

struct PlayGame_Previews: PreviewProvider {
    static var previews: some View {
        PlayGame()
    }
}
