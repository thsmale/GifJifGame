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
 * Make official rules like any other game does, let users read them, also tells them how to play
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


struct Game: Codable, Identifiable {
    var id = UUID()
    var doc_id: String = ""
    var name: String
    var players: [Player] = []
    var host: String
    var topic: String
    var time: Int
    var responses: [Response] = []
}

struct Player: Codable, Identifiable {
    var id = UUID()
    let doc_id: String
    let username: String
    
    init?(player: [String: Any]) {
        guard let doc_id = player["doc_id"] as? String,
              let username = player["username"] as? String else {
                print("Unable to decode athlete data\(player)")
                return nil
              }
        
        self.doc_id = doc_id
        self.username = username
    }
    
    init(doc_id: String, username: String) {
        self.doc_id = doc_id
        self.username = username
    }
}

//This is the content of when the user responds to the prompt
struct Response: Codable, Identifiable {
    var id = UUID()
    var gif_id: String
    var player: Player
}

//Initialize a game from user.json file stored in documents
extension Game {
    init?(game: [String: Any]) {
        guard let doc_id = game["doc_id"] as? String,
              let name = game["name"] as? String,
              let players = game["players"] as? [[String: Any]],
              let host = game["host"] as? String,
              let topic = game["topic"] as? String,
              let time = game["time"] as? Int
        else{
            print("Game unable to decode data \(game)")
            return nil
        }
        
        self.doc_id = doc_id
        self.name = name
        for player in players {
            if let athlete = Player(player: player) {
                self.players.append(athlete)
            }
        }
        self.host = host
        self.topic = topic
        self.time = time
    }
}

//Creates a game in the database
//Adds it to list of games for user in database
//Also saves it locally
//Adds to users invitations so they get alerted
func create_game(game: inout Game) -> Bool {
    //Upload to games collection
    do {
        let ref = db.collection("games").document()
        try ref.setData(from: game)
        game.doc_id = ref.documentID
        print("Game \(game.name) successfully added to database")
        //Send invitations out
        for player in game.players {
            let user_ref = db.collection("users").document(player.doc_id)
            user_ref.updateData([
                "invitations": FieldValue.arrayUnion([ref.documentID])
            ])
        }
        return true
    } catch let error {
        print("Error writing game to firestore \(error)")
        return false
    }

    
}

//Every time a game is created the data is updated by rewriting it to disc
//TODO: Append to file instead of rewriting it
func write_games(games: [Game]) -> Bool {
    print("Entering write_games")
    var data_json: Data
    do {
        data_json = try JSONEncoder().encode(games)
    } catch {
        print("Failed to encode games \(games) \(error)")
        return false
    }
    return write_json(filename: "games.json", data: data_json)
}

func submit_response(game: Game, response: Response) -> Bool {
    let ref = db.collection("games").document(game.doc_id)
    do {
        try ref.setData(from: game)
        return true
    } catch {
        print("Failed to update Game \(game.doc_id) with response")
        return false
    }
}

func get_game(game_doc_id: String, completion: @escaping ((Game?) -> Void)) {
    let docRef = db.collection("games").document(game_doc_id)
    
    docRef.getDocument { (document, error) in
        if let document = document, document.exists {
            if let data = document.data() {
                if let game = Game(game: data) {
                    completion(game)
                    return
                }
            } else {
                print("data received is empty")
                completion(nil)
            }
        } else {
            print("Document id \(game_doc_id) does not exist")
            completion(nil)
        }
        if (error != nil) {
            print("Error \(String(describing: error))")
            completion(nil)
        }
    }
}
