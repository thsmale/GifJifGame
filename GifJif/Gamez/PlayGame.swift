//
//  PlayGame.swift
//  GifJif
//
//  Created by Tommy Smale on 9/21/22.
//

import SwiftUI
import GiphyUISDK

struct PlayGame: View {
    @State var game: Game
    @State private var show_task: Bool = false
    @State private var time_remaining = 0
    @State private var timer = Timer.publish(every: 1, tolerance: nil, on: .main, in: .common, options: nil).autoconnect()
    @State var times_up: Bool = false
    @State var player: User
    @State private var topic: String = ""
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
    @State private var show_giphy: Bool = false
    @State private var giphy: URL?
    @State private var giphy_media: GPHMedia?
    @State private var mediaView = GPHMediaView()
    var view = UIView()
    //Safari
    @State private var safari: Bool = false
   
    @State private var valid_input: Bool = false
    @State private var preview: UIImage?
    @State private var show_preview: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                Text("Game information").font(.headline)
                Text("Players")
                List(game.player_usernames, id: \.self) {username in
                    Text(username)
                }
                Text("Host")
                if (game.host == player.username) {
                    TextField("Topic: ", text: $game.topic)
                    Button(action: {}) {
                        Text("Send topic")
                    }
                } else {
                    Text("Waiting for all responses...")
                    Text("Waiting for host to decide...")
                }
                Text("Time: \(game.time) seconds")
                Text("Leaderboard: ")
                
                
                if (!show_task) {
                    Button(action: {
                        show_task = true
                        time_remaining = game.time
                    }) {
                        Text("View task")
                    }
                }
                
                if (show_task) {
                    Text("Task: \(game.topic)")
                    Text("\(time_remaining)")
                        .onReceive(timer) { _ in
                            if (time_remaining <= 0) {
                                times_up = true
                            } else {
                                time_remaining -= 1
                            }
                        }
                    if(giphy_media != nil) {
                        ShowMedia(mediaView: $mediaView, media: $giphy_media)
                    }
                    //Timer
                    HStack {
                        Button("Gif", action: {
                            show_giphy.toggle()
                        })
                        /*
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
                         Button("Draw", action: {
                         draw.toggle()
                         })
                         */
                    }
                    
                    Button("Submit", action: {
                        //submit_response(giphy_media!.id)
                    }).disabled({
                        if(giphy_media == nil) {
                            return false
                        }
                        return true
                    }())
                }
                
            }
            .navigationTitle(Text(game.name))
            .sheet(isPresented: $show_image_picker) {
                ImagePicker(image: $image)
            }
            .sheet(isPresented: $show_camera) {
                Camera(image: $image)
            }
            .sheet(isPresented: $safari) {
                Safari()
            }
            .sheet(isPresented: $show_giphy) {
                GiphyUI(url: $giphy, media: $giphy_media, media_view: $mediaView)
            }
            .sheet(isPresented: $show_preview) {
                if preview != nil {
                    Image(uiImage: preview!)
                }
            }
            .alert("Times up", isPresented: $times_up) {
                Button("OK", role: .cancel) {}
            }
            

             
        }
        .navigationViewStyle(StackNavigationViewStyle())

    }
    
    var canvas: some View {
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
        .frame(width: 300, height: 300)
    }
}

extension View {
    func snapshot() -> UIImage {
            let controller = UIHostingController(rootView: self)
            let view = controller.view

            let targetSize = controller.view.intrinsicContentSize
            view?.bounds = CGRect(origin: .zero, size: targetSize)
            view?.backgroundColor = .clear

            let renderer = UIGraphicsImageRenderer(size: targetSize)

            return renderer.image { _ in
                view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
            }
        }
}
