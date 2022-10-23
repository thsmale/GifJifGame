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
        FirebaseApp.configure()

        if let user = read_user() {
            print("Successfully read \(user) from user.json")
            player_one.user = user
            player_one.user_listener()
        }
        player_one.read_games()
    }
    
    var body: some Scene {
        WindowGroup {
            Home(player_one: player_one)
        }
    }
}
