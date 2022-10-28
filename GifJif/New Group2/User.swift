//
//  User.swift
//  GifJif
//
//  Created by Tommy Smale on 9/18/22.
//

import Foundation
import FirebaseFirestore

let MAX_USERNAME_LENGTH = 30
let MAX_PASSWORD_ATTEMPT = 10

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
}

//Initializers for user
extension User {
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

//User methods that interact with the database
extension User {
    //TODO: Make non void function
    //When player creates a new game add game_doc_id to player doc
    func add_game_doc_id(game_doc_id: String) {
        //Upload doc_id to user data stored in cloud
        db.collection("users").document(self.doc_id).updateData([
            "game_doc_ids": FieldValue.arrayUnion([game_doc_id])
        ])
    }
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
func get_user(username: String) async -> User? {
    print("Entering get_user")
    do {
        let querySnapshot = try await db.collection("users").whereField("username", isEqualTo: username).getDocuments()
        if (querySnapshot.documents.isEmpty) {
            print("No documents found for \(username)")
            return nil
        }
        let doc = querySnapshot.documents[0]
        if let user = User(json: doc.data()) {
            return user
        }
    } catch {
        print("get_user() \(error)")
    }
    return nil
}





