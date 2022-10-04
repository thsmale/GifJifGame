//
//  model.swift
//  GifJif
//
//  Created by Tommy Smale on 9/17/22.
//

/*
 Game
 Topics: Choose from a genre. Pick a topic or have one generated from you
 Mode: Describe's what the host is looking for, funny, serious, mean..
 Content: People can send gif, text, stickers, drawing, picture...
 Time: People have 60 seconds for a response, but can respond whenever is convenient. Can set a deadline for response or edit amount of time they have
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
 * Add some incentive to the game. Prize money for winning the round
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

struct Game: Codable, Identifiable {
    var id = UUID()
    var doc_id: String = ""
    var name: String
    var player_usernames: [String] //All the usernames
    var host: String
    var category: String
}

func create_game(game: inout Game) -> Bool {
    var game_json: Data
    do {
        game_json = try JSONEncoder().encode(game)
    } catch {
        print("Unable to convert game to json")
        return false
    }
    let game_str = String(data: game_json, encoding: .utf8) ?? ""
    if(game_str == "") {
        print("Failed to convert type Data to string")
        return false
    }
    var ret: Bool = true
    var ref: DocumentReference? = nil
    ref = db.collection("games").addDocument(data: ["game": game_str]) { err in
        if let err = err {
            print("Error adding document: \(err)")
            ret = false
        } else {
            print("Document added with id \(ref!.documentID)")
        }
    }
    if(ret) {
        game.doc_id = ref!.documentID
        device_owner.games.append(game)
        print(device_owner.games)
    }
    return ret
}

struct Category: Identifiable, Hashable {
    var value: String = ""
    let id = UUID()
}

func read_categories() -> [Category] {
    let filepath = Bundle.main.resourcePath! + "/categories.txt"
    let file_handler = FileHandle(forReadingAtPath: filepath) ?? nil
    if(file_handler == nil) {
        print("Unable to create FileHandle for categories.txt")
        return [Category(value: "Failed to load categories")]
    }
    var categories: [Category] = []
    do {
        let data: Data = try file_handler!.readToEnd() ?? Data()
        if(data.isEmpty == true) {
            print("categories.txt readToEnd() failed")
            return [Category(value: "Failed to load categories")]
        }
        let category_values = String(decoding: data, as: UTF8.self)
            .split(separator: "\n")
        for category_value in category_values {
            var category: Category = Category()
            category.value = String(category_value)
            categories.append(category)
        }
    } catch {
        print("Unable to read categories.txt")
        return [Category(value: "Failed to load categories")]
    }
    return categories
}


