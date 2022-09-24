//
//  PlayGame.swift
//  GifJif
//
//  Created by Tommy Smale on 9/21/22.
//

import SwiftUI

struct PlayGame: View {
    @State private var topic: String = "Take the most funny photo"
    //Text
    @State private var show_text_field: Bool = false
    @State private var text_input: String = ""
    //Drawing
    @State private var draw: Bool = false
    @State private var line: Path = Path()
    @State private var new_drag: Bool = false
    //Images
    @State private var show_image_picker = false
    @State private var show_camera = false
    @State private var image: UIImage?
    //Gifs
    @State private var gif_search: String = ""
    @State private var gif: Bool = false
    //Safari
    @State private var safari: Bool = false

    
    var body: some View {
        NavigationView {
            VStack{
                Text("Task: \(topic)")
                Text("Mode: funny")
                Text("Time: 60 seconds")
                
                Canvas { context, size in
                    if(draw) {
                        context.stroke(line, with: .color(.green), lineWidth: 7)
                    }
                    if(image != nil) {
                        context.draw(Image(uiImage: image!), in: CGRect(x: 0, y: 0, width: size.width, height: size.height), style: FillStyle())
                    }
                    if(!text_input.isEmpty) {
                        context.draw(Text(text_input), in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
                    }
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
                    }).disabled(true)
                    Button("Text", action: {
                        show_text_field.toggle()
                    })
                    Button("Safari", action: {
                        safari.toggle()
                    })
                    Button("Photos", action: {
                        show_image_picker.toggle()
                    })
                    Button("Camera", action: {
                        show_camera.toggle()
                    })
                    Button("Meme", action: {}).disabled(true)
                    Button("Draw", action: {
                        draw.toggle()
                    })
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
                
                if(show_text_field) {
                    TextField("Enter text response", text: $text_input)
                }
                
                Button("Submit", action: {})
            }
            .navigationTitle(Text("Game"))
            .sheet(isPresented: $show_image_picker) {
                ImagePicker(image: $image)
            }
            .sheet(isPresented: $show_camera) {
                Camera(image: $image)
            }
            .sheet(isPresented: $safari) {
                Safari()
            }
             
        }
        .navigationViewStyle(StackNavigationViewStyle())

    }
}

struct PlayGame_Previews: PreviewProvider {
    static var previews: some View {
        PlayGame()
    }
}
