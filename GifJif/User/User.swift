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
    var invintations: [String]
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
        self.invintations = []
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
              let invintations = json["invintations"] as? [Any]
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
        self.invintations = []
        
        for case let invintation as String in invintations {
            self.invintations.append(invintation)
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
            "games": FieldValue.arrayUnion([game_doc_id])
        ])
    }
}


//A wrapper for save_user_locally for when a user is signing into their account
//TODO: Custom object in firestore (add data to firestore) you can get rid of this
func save_user_locally(doc_id: String, data: Dictionary<String, Any>) -> Bool {
    var new_data: Dictionary<String, String> = [:]
    guard let username = data["username"] as? String else {
        print("save_user_locally cannot find username in dict")
        return false
    }
    guard let password = data["password"] as? String else {
        print("save_user_locally cannot find password in dict")
        return false
    }
    if let first_name = data["first_name"] as? String {
        new_data["first_name"] = first_name
    } else {
        new_data["first_name"] = ""
    }
    if let last_name = data["last_name"] as? String{
        new_data["last_name"] = last_name
    } else {
        new_data["last_name"] = ""
    }
    if let email = data["email"] as? String {
        new_data["email"] = email
    } else {
        new_data["email"] = ""
    }
    
    new_data["doc_id"] = doc_id
    new_data["username"] = username
    new_data["password"] = password
    
    return save_user_locally(data: new_data)
}
 
func save_user_locally(data: Dictionary<String, String>) -> Bool {
    var data_json: Data
    do {
        data_json = try JSONEncoder().encode(data)
    } catch {
        print("Error encoding user dict to json \(error)")
        return false
    }
    
    return write_json(filename: "user.json", data: data_json)
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

//Check the database for a username
//When player is creating a game and adding other players
//TODO: pass in a doc_id then get data
func get_user(username: String) async -> User? {
    var user: User? = nil
    do {
        let querySnapshot = try await db.collection("users").whereField("username", isEqualTo: username).getDocuments()
        if (querySnapshot.documents.isEmpty) {
            return nil
        }
        let doc = querySnapshot.documents[0]
        print("Read user w/ id \(doc.documentID) and data \(doc.data())")
        //user = User(doc_id: doc.documentID, data: doc.data())
        print("player: \(String(describing: user))")
    } catch {
        print("get_user() \(error)")
    }
    return user
}





