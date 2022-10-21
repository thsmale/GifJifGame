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
    //This will try to add a user to the database
    //Called when user creates an account
    mutating func create_user() -> Bool {
        let ref = db.collection("users").document()
        do {
            try ref.setData(from: self)
            self.doc_id = ref.documentID
            print("User \(self.username) successfully added to database")
            return true
        } catch let error {
            print("Error writing game to firestore \(error)")
            return false
        }
    }
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
}

//This is the owner of the device
//This retrives their account settings
func read_user() -> User {
    var user: User
    if let user_data = read_json(filename: "user.json") {
        if (user_data as? [String: Any] == nil) {
            user = User()
            print("Data read from user.json not acceptable")
        } else {
            user = User(json: user_data as! [String: Any]) ?? User()
        }
    } else {
        user = User()
    }
    return user
}

//Finds username and password in database, saves user locally
func sign_in(_ username: String, _ password: String) async -> User? {
    print("Entering sign_in")
    do {
        let querySnapshot = try await db.collection("users").whereField("username", isEqualTo: username).whereField("password", isEqualTo: password).getDocuments()
        if (querySnapshot.documents.isEmpty) {
            print("Found no docs for \(username)")
            return nil
        }
        let doc = querySnapshot.documents[0]
        if let user = User(json: doc.data()) {
            print("Sign in successful")
            return user
        }
    } catch {
        print("get_user() \(error)")
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





