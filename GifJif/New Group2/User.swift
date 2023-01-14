//
//  User.swift
//  GifJif
//
//  Created by Tommy Smale on 9/18/22.
//

import Foundation
import FirebaseFirestore



//Return username of user
//To handle ID: Do not let user create game unless they have an account
//Check if user has an account by seeing doc_id is not ""
struct User: Identifiable, Codable {
    var id: UUID
    var doc_id: String
    var username: String
    var password: String
    var first_name: String
    var last_name: String
    var email: String
    var game_doc_ids: [String]
    var invitations: [String]
    
    //When a user does not have an account
    //Useful for storing their games
    init() {
        self.id = UUID()
        self.doc_id = ""
        self.username = ""
        self.password = ""
        self.first_name = ""
        self.last_name = ""
        self.email = ""
        self.game_doc_ids = []
        self.invitations = []
    }
    
    //Used when creating a User
    init(username: String, password: String, first_name: String, last_name: String, email: String) {
        self.id = UUID()
        self.doc_id = ""
        self.username = username
        self.password = password
        self.first_name = first_name
        self.last_name = last_name
        self.email = email
        self.game_doc_ids = []
        self.invitations = []
    }
    
    //Used for initializing device owner from user.json file stored in documents
    init?(json: [String: Any]) {
        //Verify all of the types
        guard let doc_id = json["doc_id"] as? String,
              let username = json["username"] as? String,
              let password = json["password"] as? String,
              let first_name = json["first_name"] as? String,
              let last_name = json["last_name"] as? String,
              let email = json["email"] as? String,
              let game_doc_ids = json["game_doc_ids"] as? [Any],
              let invitations = json["invitations"] as? [Any]
        else {
            print("User unable to decode user \(json)")
            return nil
        }
        
        self.id = UUID()
        self.doc_id = doc_id
        self.username = username
        self.password = password
        self.first_name = first_name
        self.last_name = last_name
        self.email = email
        self.game_doc_ids = []
        self.invitations = []
        
        for case let doc_id as String in game_doc_ids {
            self.game_doc_ids.append(doc_id)
        }
        
        for case let invitation as String in invitations {
            self.invitations.append(invitation)
        }
    }
}

//A ligher weight User for identifying who sent what response
//Invitation used for inviting players, if it has a value, signifies user has not yet accepted invitation
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
}

//User methods that interact with the database
extension User {
    func save_locally() -> Bool {
        print("Entering save locally")
        var data_json: Data
        do {
            data_json = try JSONEncoder().encode(self)
            return write_json(filename: "user.json", data: data_json)
        } catch {
            print("Failed to encode User \(self) \(error)")
            return false
        }
    }
    //Called by the sign out function
    //Need it cause you can't just set games and user to games() user()
    func reset_vals() {
        
    }
}

//Make these guys Players maybe
let bots: [Player] = [Player(doc_id: "IxTyYIXKrU2cARTh47Ej", username: "Robo twerkulator"),
                   Player(doc_id: "ofhD0rxecPvokkzOmOLX", username: "Todd"),
                   Player(doc_id: "27VewoWFoIMsaiDMDlrN" ,username: "Botty Mac"),
                   Player(doc_id: "6faAT06m1BAc9W76uEMS" ,username: "None")]

//Get account data from local file saved on device
//Data returned from read_json is of type Any
func read_user() -> User? {
    print("Entering read_user")
    if let user_data = read_json(filename: "user.json") as? [String: Any] {
        if let user = User(json: user_data) {
            return user
        }
    } else {
        print("user.json unable to be casted to [string: any]")
    }
    return nil
}


//Check the database for a username
//When player is creating a game and adding other players
//TODO: Return Player instead. Just get the fields you want
func get_user(username: String, completion: @escaping ((User?) -> Void)) {
    db.collection("users").whereField("username", isEqualTo: username).getDocuments() { querySnapshot, error in
        if let error = error {
            print("get_user Error retriveing the collection \(error)")
            completion(nil)
            return
        }
        guard let documents = querySnapshot?.documents else {
            print("get_user Error fetching documents: \(error!)")
            completion(nil)
            return
        }
        if (documents.count <= 0) {
            print("get_user No documents found for \(username)")
            completion(nil)
            return
        }
        if var user = User(json: documents[0].data()) {
            if (user.doc_id == "") {
                user.doc_id = documents[0].documentID
            }
            completion(user)
        }
    }
}

//This will try to add a user to the database
//Called when user creates an account
//TODO: Set val of user.doc_id before submitting using ref
func create_account(user: User, completion: @escaping ((String?) -> Void)) {
    print("Entering create account")
    let ref = db.collection("users").document()
    do {
        try ref.setData(from: user) { err in
            if let err = err {
                print("Failed to create account \(err)")
                completion(nil)
            } else {
                print("Successfully created account")
                completion(ref.documentID)
            }
        }
    } catch let error {
        print("Error creating account \(error)")
        completion(nil)
    }
}



