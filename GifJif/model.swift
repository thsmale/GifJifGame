//
//  model.swift
//  GifJif
//
//  Created by Tommy Smale on 9/17/22.
//

/*
 Game
 Topics: Choose from a genre. Pick a topic or have one generated from you
 Content: People can send gif, text, stickers, drawing...
 Time: People have 60 seconds for a response, but can respond whenever is convenient
 Objective: Submit content that aligns with the topic
 Once everyone has responded, the host chooses their favorite response (annonymous)
 
 * Rounds where you get double the points
 * Add combination of adjetives and auto generate sentence based on that
 * When people send same content: host only see's unique content, selects favorite, both people win that round
 * Public and private games so people can vote (people must be actively playing)
 * Live mode and async mode
 * Birthday may be required to activate dirty mode
 * Add accolades like quickest responses
 * Add bots to play against
 * What if someone wants to share an article? May take longer than 60 seconds
 */

/*
 Actions
 * Create game: Adds to collection, games, a document. Returns document id which is stored on the device
 *
 */

/*
 Connecting devices
 Each device connects to database and reads from a document containing their game data
 */

/*
 Database
 * Collection: Users
 * Document: [username, password, email, birthday, name]
 
 * Collection: Games
 * Document: [id, group_name, players (user ids), topic, responses: [id, link_to_content]]
 * Data like topic will be accessed more than group info (cached)
 */

/*
 Local storage
 player: [id, username]
 */

import Foundation
import FirebaseFirestore

let db = Firestore.firestore()

struct Game {
    var name: String
    var players: [String]
}

func create_game(group name: String) -> Bool {
    var group_name = name
    if(group_name == "") {
        //Generate random group name if one is not supplied
        group_name = "Squeeky quack"
    }
    var ret: Bool = true
    var ref: DocumentReference? = nil
    ref = db.collection("games").addDocument(data: ["group_name": group_name]) { err in
        if let err = err {
            print("Error adding document: \(err)")
            ret = false
        } else {
            print("Document added with id \(ref!.documentID)")
        }
    }
    return ret
}

//Return username of user
struct User: Identifiable {
    var username: String = ""
    let id = UUID()
}

func get_user() -> User {
    var user: User = User()
    user.username = "tommy"
    return user
}
