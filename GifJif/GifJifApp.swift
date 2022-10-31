//
//  GifJifApp.swift
//  GifJif
//
//  Created by Tommy Smale on 9/16/22.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
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
