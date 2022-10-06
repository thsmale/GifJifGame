//
//  User.swift
//  GifJif
//
//  Created by Tommy Smale on 9/18/22.
//

import Foundation
import FirebaseFirestore

var device_owner = get_self()

//Return username of user
//To handle ID: Do not let user create game unless they have an account
//Check if user has an account by seeing doc_id is not ""
class User: Identifiable, Codable, ObservableObject {
    let id: UUID
    let doc_id: String
    var username: String
    var password: String
    var first_name: String
    var last_name: String
    var email: String
    @Published var games: [Game]
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case doc_id
        case username
        case password
        case first_name
        case last_name
        case email
        case games
    }
    
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(UUID.self, forKey: .id)
        doc_id = try values.decode(String.self, forKey: .doc_id)
        username = try values.decode(String.self, forKey: .username)
        password = try values.decode(String.self, forKey: .password)
        first_name = try values.decode(String.self, forKey: .first_name)
        last_name = try values.decode(String.self, forKey: .last_name)
        email = try values.decode(String.self, forKey: .email)
        games = try values.decode([Game].self, forKey: .games)
    }
    
    func encode(to encoder: Encoder) throws {
        
    }
    
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
        self.games = []
    }
    //Original purpose for making struct out of CreateAccount form data and the docid generated after saving user data to the database
    //TODO: User already has games saved but now is creating an account
    init?(doc_id: String, data: Dictionary<String, Any>) {
        guard let username = data["username"] as? String else {
            print("User init cannot find username in dict")
            return nil
        }
        guard let password = data["password"] as? String else {
            print("User init cannot find password in dict")
            return nil
        }
        if let first_name = data["first_name"] as? String {
            self.first_name = first_name
        } else {
            self.first_name = ""
        }
        if let last_name = data["last_name"] as? String{
            self.last_name = last_name
        } else {
            self.last_name = ""
        }
        if let email = data["email"] as? String {
            self.email = email
        } else {
            self.email = ""
        }
        
        self.id = UUID()
        self.doc_id = doc_id
        self.username = username
        self.password = password
        self.games = []
    }
    //Used for initializing device owner from user.json file stored in documents
    init?(json: [String: Any]) {
        //Verify all of the types
        guard let doc_id = json["doc_id"] as? String,
              let username = json["username"] as? String,
              let password = json["password"] as? String,
              let first_name = json["first_name"] as? String,
              let last_name = json["last_name"] as? String,
              let email = json["email"] as? String
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
        self.games = []
        
        //Verify all the games are legit
        /*
        for game in games {
            if let g = Game(game: game) {
                self.games.append(g)
            }
        }
         */
    }
    //Used for initializing player retrieved from database
    //TODO: See if there are any optional parameters, delete this duplicated code
    init?(doc_id: String, json: [String: Any]) {
        //Verify all of the types
        guard let username = json["username"] as? String,
              let password = json["password"] as? String,
              let first_name = json["first_name"] as? String,
              let last_name = json["last_name"] as? String,
              let email = json["email"] as? String,
              let games = json["games"] as? [[String: Any]]
        else {
            return nil
        }
        
        self.id = UUID()
        self.doc_id = doc_id
        self.username = username
        self.password = password
        self.first_name = first_name
        self.last_name = last_name
        self.email = email
        self.games = []
        
        //Verify all the games are legit
        for game in games {
            if let g = Game(game: game) {
                self.games.append(g)
            }
        }
    }
}


//TODO: return different error to user if issue with network than if username is taken
func available_username(username: String) async -> Bool {
    do {
        let querySnapshot = try await db.collection("users").whereField("username", isEqualTo: username).getDocuments()
        if (querySnapshot.documents.isEmpty) {
            return true
        }
    } catch {
        print("get_user() \(error)")
    }
    return false
}

//This will try to add a user to the database
//If successfull it also saves the user data locally
//TODO: Work with custom encoding to simplify all this Dictionary stuff
func add_user(user_data: inout Dictionary<String, Any>) -> Bool {
    var ret: Bool = true
    var ref: DocumentReference? = nil
    ref = db.collection("users").addDocument(data: user_data) { err in
        if let err = err {
            print("Error adding document: \(err)")
            ret = false
        }
    }
    if(ret) {
        print("Document added with id \(ref!.documentID)")
        user_data.removeValue(forKey: "games")
        if (save_user_locally(doc_id: ref!.documentID, data: user_data)) {
            print("Successfully created user.json file")
        }else {
            print("Failed to create user.json file")
        }
    }
    return ret
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
func get_self() -> User {
    var user: User
    var games: [Game] = []
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
    if let game_data = read_json(filename: "games.json") {
        if (game_data as? [[String: Any]] == nil) {
            print("Data read from games.json not acceptable")
        } else {
            //game_data = game_data as! [[String: Any]]
            for game in games as! [[String: Any]] {
                if let g = Game(game: game) {
                    games.append(g)
                }
            }
        }
    }
    user.games = games
    return user
}

//Check the database for a username
func get_user(username: String) async -> User? {
    var user: User? = nil
    do {
        let querySnapshot = try await db.collection("users").whereField("username", isEqualTo: username).getDocuments()
        if (querySnapshot.documents.isEmpty) {
            return nil
        }
        let doc = querySnapshot.documents[0]
        print("Read user w/ id \(doc.documentID) and data \(doc.data())")
        user = User(doc_id: doc.documentID, data: doc.data())
        print("player: \(String(describing: user))")
    } catch {
        print("get_user() \(error)")
    }
    print("user: \(String(describing: user))")
    return user
}

//TODO: handle data not saving
func sign_in(_ username: String, _ password: String) async -> Bool {
    do {
        let querySnapshot = try await db.collection("users").whereField("username", isEqualTo: username).whereField("password", isEqualTo: password).getDocuments()
        if (querySnapshot.documents.isEmpty) {
            return false
        }
        let doc = querySnapshot.documents[0]
        if(save_user_locally(doc_id: doc.documentID, data: doc.data())) {
            device_owner = User(doc_id: doc.documentID, data: doc.data()) ?? User()
            print("Successfully saved user data!")
        }
        if(save_games_locally(data: doc.data())) {
            print("Successfully saved game data!")
        }
        return true
    } catch {
        print("get_user() \(error)")
        return false
    }
}

//Returns something to address the user like a name or username
func get_handle() -> String {
    if(device_owner.username != "") {
        return device_owner.username
    }
    if(device_owner.first_name != "") {
        return device_owner.first_name
    }
    if(device_owner.last_name != "") {
        return device_owner.last_name
    }
    return ""
}
