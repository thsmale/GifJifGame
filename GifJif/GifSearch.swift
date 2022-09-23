//
//  GifSearch.swift
//  GifJif
//
//  Created by Tommy Smale on 9/22/22.
//

import SwiftUI

struct GifSearch: View {
    @State private var search: String = ""
    let image = Image("froggy")
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search gifs", text: $search)
                    .onSubmit {
                        if(search.count > 0) {
                            gif_search(query: search)
                        }
                    }
            }
            
            ScrollView {
                VStack {
                    ForEach(0..<12) {
                        if($0 % 3 == 0) {
                            HStack {
                                image.resizable()
                                    .frame(width: 91, height: 91)
                                image.resizable()
                                    .frame(width: 91, height: 91)
                                image.resizable()
                                    .frame(width: 91, height: 91)
                            }
                        }
                    }
                }
            }
        }
    }
}

func gif_search(query: String) {
    let api_key = ProcessInfo.processInfo.environment["giphy_api_key"]
    if (api_key == nil) {
        print("Unable to get api_key")
        return
    }
    
    let url = URL(string: "https://api.giphy.com/v1/gifs/search?api_key=" + api_key! + "&q=" + query + "&limit=9&offset=0&rating=g&lang=en")
    print("URL: \(String(describing: url))")
    if (url == nil) {
        print("Failed to create url")
        return
    }
    
    let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
        guard let data = data else { return }
        print(String(data: data, encoding: .utf8)!)
    }
    task.resume()
    
}

struct GifSearch_Previews: PreviewProvider {
    static var previews: some View {
        GifSearch()
    }
}
