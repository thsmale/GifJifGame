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

//TODO: Change winner to optional
struct Game: Codable, Identifiable {
    var id = UUID()
    var doc_id: String = ""
    var name: String
    var players: [Player] = []
    var host: Player
    var topic: String
    var time: Int
    var responses: [Response] = []
    var winner: Response? = nil
    
    //for CreateGame
    init(name: String, players: [Player], host: Player, topic: String, time: Int) {
        self.name = name
        self.players = players
        self.host = host
        self.topic = topic
        self.time = time
    }
    
    //For dealing with json data
    init?(game: [String: Any]) {
        guard let doc_id = game["doc_id"] as? String,
              let name = game["name"] as? String,
              let players = game["players"] as? [[String: Any]],
              let host = game["host"] as? [String: Any],
              let topic = game["topic"] as? String,
              let time = game["time"] as? Int,
              let responses = game["responses"] as? [[String: Any]]
        else{
            print("Game unable to decode data \(game)")
            return nil
        }
        
        //TODO: Handle if players or responses failed to initialize
        self.doc_id = doc_id
        self.name = name
        for player in players {
            if let athlete = Player(player: player) {
                self.players.append(athlete)
            }
        }
        self.host = Player()
        if let host = Player(player: host) {
            self.host = host
        }
        self.topic = topic
        self.time = time
        for response in responses {
            if let res = Response(response: response) {
                self.responses.append(res)
            }
        }
        if let winner = game["winner"] as? [String: Any] {
            if let winner = Response(response: winner) {
                self.winner = winner
            }
        }
    }
    
    mutating func set_doc_id(doc_id: String) {
        self.doc_id = doc_id
    }
}

//A ligher weight User for identifying who sent what response
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
    
    //Used for picker's, like CreateGame need player in add_players to match id of player_one
    init(id: UUID, doc_id: String, username: String) {
        self.id = id
        self.doc_id = doc_id
        self.username = username
    }
    
    //Used as placeholder for winner
    init() {
        self.doc_id = ""
        self.username = ""
    }
}

//This is the content of when the user responds to the prompt
struct Response: Codable, Identifiable {
    var id = UUID()
    var gif_id: String
    var player: Player
    
    init?(response: [String: Any]) {
        guard let gif_id = response["gif_id"] as? String,
              let player = response["player"] as? [String: Any] else {
            print("Unable to decode response \(response)")
            return nil
        }
        
        self.gif_id = gif_id
        if let playa = Player(player: player) {
            self.player = playa
        } else {
            print("response Unable to decode player \(player)")
            return nil
        }
    }
    
    init(gif_id: String, player: Player) {
        self.gif_id = gif_id
        self.player = player
    }
    
}

struct Winner: Codable, Identifiable {
    var id = UUID()
    var topic: String
    var response: Response
}

extension PlayerOne {
    //Creates a game in the database
    //Adds it to list of games for user in database
    //Also saves it locally
    //Adds to users invitations so they get alerted
    //NOTE doc_id in database will be ""
    func create_game(game: Game, completion: @escaping ((String?) -> Void)) {
        //Upload to games collection
        do {
            let ref = db.collection("games").document()
            try ref.setData(from: game) { [self] err in
                if let err = err {
                    print("Error adding game: \(err)")
                    completion(nil)
                } else {
                    print("Game \(game.name) successfully added to database with doc_id \(ref.documentID)")
                    var game = game
                    game.doc_id = ref.documentID
                    self.games.append(game)
                    self.add_game_doc_id(game_doc_id: ref.documentID, completion: {_ in })
                    self.game_listener(game_doc_id: ref.documentID)
                    //Send invitations out except to self
                    for player in game.players {
                        if (player.doc_id == user.doc_id) {
                            continue
                        }
                        let user_ref = db.collection("users").document(player.doc_id)
                        user_ref.updateData([
                            "invitations": FieldValue.arrayUnion([ref.documentID])
                        ]) { err in
                            if let err = err {
                                print("Failed to send invitation to \(player.username) \(err)")
                            }
                        }
                    }
                    completion(ref.documentID)
                }
            }
        } catch let error {
            print("Error writing game to firestore \(error)")
            completion(nil)
        }
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

func submit_response(doc_id: String, response: Response, completion: @escaping ((Bool) -> Void)) {
    print("Submitting response...")
    let encoded_response: [String: Any]
    do {
        // encode the swift struct instance into a dictionary
        // using the Firestore encoder
        encoded_response = try Firestore.Encoder().encode(response)
    } catch {
        // encoding error
        print("submit_response Error encoding response \(error)")
        completion(false)
        return
    }
    let ref = db.collection("games").document(doc_id)
    ref.updateData([
        "responses": FieldValue.arrayUnion([encoded_response])
    ]) { err in
        if let err = err {
            print("Error updating response for game \(doc_id): \(err)")
            completion(false)
        } else {
            print("Responses for game \(doc_id) successfully updated")
            completion(true)
        }
    }
}

func submit_winner(doc_id: String, winner: Response, completion: @escaping ((Bool) -> Void)) {
    print("Submitting winner...")
    let encoded_response: [String: Any]
    do {
        // encode the swift struct instance into a dictionary
        // using the Firestore encoder
        encoded_response = try Firestore.Encoder().encode(winner)
    } catch {
        // encoding error
        print("Error encoding response \(error)")
        completion(false)
        return
    }
    let ref = db.collection("games").document(doc_id)
    ref.updateData([
        "winner": encoded_response
    ]) { err in
        if let err = err {
            print("Error updating document: \(err)")
            completion(false)
        } else {
            print("Document successfully updated")
            completion(true)
        }
    }
}

func add_player(doc_id: String, player: Player, completion: @escaping ((Bool) -> Void)) {
    print("Adding player...")
    let encoded_player: [String: Any]
    do {
        // encode the swift struct instance into a dictionary
        // using the Firestore encoder
        encoded_player = try Firestore.Encoder().encode(player)
    } catch {
        // encoding error
        print("Error encoding player \(error)")
        completion(false)
        return
    }
    let ref = db.collection("games").document(doc_id)
    ref.updateData([
        "players": FieldValue.arrayUnion([encoded_player])
    ]) { err in
        if let err = err {
            print("Error updating document: \(err)")
            completion(false)
        } else {
            print("Document successfully updated")
            completion(true)
        }
    }
}

func start_round(doc_id: String, topic: String, time: Int, completion: @escaping ((Bool) -> Void)) {
    print("Starting new round...")
    let ref = db.collection("games").document(doc_id)
    ref.updateData([
        "topic": topic, "time": time, "winner": FieldValue.delete(), "responses": []
    ]) { err in
        if let err = err {
            print("Error starting round: \(err)")
            completion(false)
        } else {
            print("Round successfully started")
            completion(true)
        }
    }
}


func end_round(doc_id: String, host: Player, completion: @escaping ((Bool) -> Void)) {
    print("Ending round...")
    let encoded_player: [String: Any]
    do {
        encoded_player = try Firestore.Encoder().encode(host)
    } catch {
        print("Error encoding player \(error)")
        completion(false)
        return
    }
    let ref = db.collection("games").document(doc_id)
    ref.updateData([
        "topic": "", "host": encoded_player
    ]) { err in
        if let err = err {
            print("Error ending round: \(err)")
            completion(false)
        } else {
            print("Sucessfully ended round")
            completion(true)
        }
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
                print("get_game data received is empty")
                completion(nil)
            }
        } else {
            print("get_game Document id \(game_doc_id) does not exist")
            completion(nil)
        }
        if (error != nil) {
            print("get_game Error \(String(describing: error))")
            completion(nil)
        }
    }
}

