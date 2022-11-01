//
//  GifJifApp.swift
//  GifJif
//
//  Created by Tommy Smale on 9/16/22.
//

import SwiftUI
import FirebaseCore
import GiphyUISDK


class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        print("application go bye bye")
    }

}

@main
struct GifJifApp: App {
    //Register app delegate for firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @ObservedObject var player_one = PlayerOne()

    init() {
        print("-----Setting up game------")
        FirebaseApp.configure()
        //TODO: More secure way to store this
        let api_key = "43xGIGAz4Lf5Hh6hqqUhvzoZPcJXCPKm"
        Giphy.configure(apiKey: api_key)
        //TODO: Save each acount to it's own file
        //  Have some way to read locally whoever is signed in so load their data 
        if let user = read_user() {
            print("Successfully read \(user) from user.json")
            player_one.user = user
            player_one.user_listener()
            player_one.load_games()
        }
        print("-----------------------------\n")
    }
    
    var body: some Scene {
        WindowGroup {
            Home(player_one: player_one)
        }
    }
}
