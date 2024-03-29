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
 * Add bots to play against, would work well for one player
 * Add some incentive to the game. Prize money for winning the round
 * Make official rules like any other game does, let users read them, also tells them how to play
 * Democracy mode where everyone votes on their favorite gif, dictator mode (he decides winner), socialist mode (everyone wins)
 * Time to pick gif vs deadline (everyone must respond by...)
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
    var host: Player
    var topic: String
    var time: Int
    var deadline: Date?
    var responses: [Response] = []
    var winner: Winner? = nil
    var winners: [Winner] = []
    var public_game: Bool = false
    var invitations: [String] = []
    
    //for CreateGame
    init(name: String, players: [Player], host: Player, topic: String, time: Int, deadline: Date?, public_game: Bool, invitations: [String]) {
        self.name = name
        self.players = players
        self.host = host
        self.topic = topic
        self.time = time
        if let deadline = deadline {
            self.deadline = deadline
        }
        self.public_game = public_game
        self.invitations = invitations
    }
    
    //For dealing with json data
    init?(game: [String: Any]) {
        guard let doc_id = game["doc_id"] as? String else {
            print("Game unable to decode doc_id \(game)")
            return nil
        }
        guard let name = game["name"] as? String else {
            print("Game unable to decode name \(game)")
            return nil
        }
        guard let players = game["players"] as? [[String: Any]] else {
            print("Game unable to decode players \(game)")
            return nil
        }
        guard let host = game["host"] as? [String: Any] else {
            print("Game unable to decode host \(game)")
            return nil
        }
        guard let topic = game["topic"] as? String else {
            print("Game unable to decode topic \(game)")
            return nil
        }
        guard let time = game["time"] as? Int else {
            print("Game unable to decode time \(game)")
            return nil
        }
        guard let responses = game["responses"] as? [[String: Any]] else {
            print("Game unable to decode responses \(game)")
            return nil
        }
        guard let winners = game["winners"] as? [[String: Any]] else {
            print("Game unable to decode winners \(game)")
            return nil
        }
        guard let public_game = game["public_game"] as? Bool else {
            print("Game unable to decode public_game \(game)")
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
        if let host = Player(player: host) {
            self.host = host
        } else {
            print("Failed to decode host")
            return nil
        }
        self.topic = topic
        self.time = time
        if let deadline = game["deadline"] as? Date {
            self.deadline = deadline
        }
        for response in responses {
            if let res = Response(response: response) {
                self.responses.append(res)
            }
        }
        if let winner = game["winner"] as? [String: Any] {
            if let winner = Winner(winner: winner) {
                self.winner = winner
            }
        }
        for winner in winners {
            if let winner = Winner(winner: winner) {
                self.winners.append(winner)
            }
        }
        self.public_game = public_game
        if let invitations = game["invitations"] as? [String] {
            for invitation in invitations {
                self.invitations.append(invitation)
            }
        }
    }
    
    mutating func set_doc_id(doc_id: String) {
        self.doc_id = doc_id
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

//TODO: Implement some kind of decoder
struct Winner: Codable, Identifiable {
    var id = UUID()
    var topic: String
    var response: Response
    
    init?(winner: [String: Any]) {
        guard let topic = winner["topic"] as? String,
              let response = winner["response"] as? [String: Any] else {
            print("Unable to decode winner \(winner)")
            return nil
        }
        
        self.topic = topic
        if let response = Response(response: response) {
            self.response = response
        } else {
            return nil
        }
    }
    
    //Used for making a copy of the @state variable winner used by host to pick the winner
    init(topic: String, response: Response) {
        self.topic = topic
        self.response = response
    }
}

//Bots are good for solo play, or eventually adding them to a game
//Utilize 'artificial intelligence' to make them playable
struct Bot: Identifiable {
    let id = UUID()
    var name: String
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
                    for invitation in game.invitations {
                        send_invitation(user_doc_id: invitation, game_doc_id: ref.documentID)
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

func submit_winner(doc_id: String, winner: Winner, completion: @escaping ((Bool) -> Void)) {
    print("Submitting winner...")
    let encoded_winner: [String: Any]
    do {
        // encode the swift struct instance into a dictionary
        // using the Firestore encoder
        encoded_winner = try Firestore.Encoder().encode(winner)
    } catch {
        // encoding error
        print("submit_winner Error encoding response \(error)")
        completion(false)
        return
    }
    let ref = db.collection("games").document(doc_id)
    ref.updateData([
        "winner": encoded_winner,
        "winners": FieldValue.arrayUnion([encoded_winner])
    ]) { err in
        if let err = err {
            print("submit_winner Error updating document: \(err)")
            completion(false)
        } else {
            print("submit_winner Document successfully updated")
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

func start_round(doc_id: String, topic: String, time: Int, deadline: Date?, completion: @escaping ((Bool) -> Void)) {
    print("Starting new round...")
    let ref = db.collection("games").document(doc_id)
    ref.updateData([
        "topic": topic, "time": time, "winner": FieldValue.delete(), "responses": [],
        "deadline": (deadline != nil) ? deadline! : FieldValue.delete()
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

func get_public_games(completion: @escaping(([Game]) -> Void)) {
    db.collection("games").whereField("public_game", isEqualTo: true).limit(to: 5)
        .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("get_public_games Error getting documents: \(err)")
                completion([])
            } else {
                var games: [Game] = []
                for document in querySnapshot!.documents {
                    if var game = Game(game: document.data()) {
                        if (game.doc_id == "") {
                            game.doc_id = document.documentID
                        }
                        games.append(game)
                    } else {
                        print("public_games failed to decode \(document.data())")
                    }
                }
                completion(games)
            }
        }
}

//TODO: Handle error better
func send_invitation(user_doc_id: String, game_doc_id: String) {
    let user_ref = db.collection("users").document(user_doc_id)
    user_ref.updateData([
        "invitations": FieldValue.arrayUnion([game_doc_id])
    ]) { err in
        if let err = err {
            print("send_invitation failed to send invitation \(game_doc_id) to \(user_doc_id) \(err)")
        }
    }
}


