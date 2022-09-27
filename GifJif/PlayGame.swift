//
//  PlayGame.swift
//  GifJif
//
//  Created by Tommy Smale on 9/21/22.
//

import SwiftUI
import GiphyUISDK

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

    var body: some View {
        NavigationView {
            VStack {
                Text("Task: \(topic)")
                Text("Mode: funny")
                Text("Time: 60 seconds")
                
                if(giphy_media != nil) {
                    ShowMedia(mediaView: $mediaView, media: $giphy_media)
                }
                
                //canvas

                
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
                
                if(show_text_field) {
                    TextField("Enter text response", text: $text_input)
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
            .sheet(isPresented: $show_giphy) {
                GiphyUI(url: $giphy, media: $giphy_media, media_view: $mediaView)
            }
            .sheet(isPresented: $show_preview) {
                if preview != nil {
                    Image(uiImage: preview!)
                }
            }
             
            

             
        }
        .navigationViewStyle(StackNavigationViewStyle())

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

struct PlayGame_Previews: PreviewProvider {
    static var previews: some View {
        PlayGame()
    }
}
