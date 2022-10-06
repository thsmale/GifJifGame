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
import FirebaseFirestoreSwift

let db = Firestore.firestore()

struct Game: Codable, Identifiable {
    var id = UUID()
    var doc_id: String = ""
    var name: String
    var player_usernames: [String] //All the usernames
    var host: String
    var category: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case doc_id
        case name
        case player_usernames
        case host
        case category
    }
}

//Initialize a game from user.json file stored in documents
extension Game {
    init?(game: [String: Any]) {
        guard let doc_id = game["doc_id"] as? String,
              let name = game["name"] as? String,
              let player_usernames = game["player_usernames"] as? [Any],
              let host = game["host"] as? String,
              let category = game["category"] as? String
        else{
            print("Game unable to decode data \(game)")
            return nil
        }
        for player in player_usernames {
            guard player is String
            else{
                print("Game unable to decode player_usernames in game \(player_usernames)")
                return nil
            }
        }
        
        self.doc_id = doc_id
        self.name = name
        self.player_usernames = player_usernames as! [String]
        self.host = host
        self.category = category
    }
}

//Creates a game in the database
//Adds it to list of games for user in database
//Also saves it locally
func create_game(game: inout Game) -> Bool {
    //Upload to games collection
    let ref = db.collection("games").document()
    do {
        try ref.setData(from: game)
        game.doc_id = ref.documentID
        device_owner.games.append(game)
        //Upload doc_id to user data stored in cloud
        if(device_owner.doc_id != "") {
            db.collection("users").document(device_owner.doc_id).updateData([
                "games": FieldValue.arrayUnion([ref.documentID])
            ])
        }
        //Save game data locally
        if(!write_games(games: device_owner.games)) {
            print("Failed to save games locally")
        }
        return true
    } catch let error {
        print("Error writing game to firestore \(error)")
        return false
    }
}

//Every time a game is created the data is updated by rewriting it to disc
func write_games(games: [Game]) -> Bool {
    var data_json: Data
    do {
        data_json = try JSONEncoder().encode(games)
    } catch {
        print("Failed to encode games \(games) \(error)")
        return false
    }
    print("Save this: " + String(data: data_json, encoding: .utf8)!)
    return write_json(filename: "games.json", data: data_json)
}

//After a user signs in, this saves the data to the device locally
//TODO: Do not over write already saved data
func save_games_locally(data: [String: Any]) -> Bool {
    guard let game_doc_ids = data["games"] as? [String] else {
        print("Could not find games array from \(data)")
        return false
    }
    var games: [Game] = []
    for doc_id in game_doc_ids {
        if (doc_id.isEmpty) {
            continue
        }
        let doc_ref = db.collection("games").document(doc_id)
        doc_ref.getDocument(as: Game.self) { result in
            switch result {
            case .success(let game):
                games.append(game)
            case .failure(let error):
                print("Error decoding game from database \(error)")
            }
        }
    }
    device_owner.games = games
    return write_games(games: games)
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


