//
//  Model.swift
//  GifJif
//
//  Created by Tommy Smale on 10/4/22.
//

/*
 These are functions/code that both Game and User can share
 Goal is to reduce the amount of repeated code
 */
import Foundation
import FirebaseFirestore

//TODO: Remove this global variable
let db = Firestore.firestore()
let MAX_USERNAME_LENGTH = 30
let MAX_PASSWORD_ATTEMPT = 10
let MAX_TOPIC_LENGTH = 140

//TODO: Update local first or database first, then update local???
class PlayerOne: ObservableObject {
    @Published var user: User
    @Published var games: [Game]
    private var listeners: [Listener] = []
    
    //Note that doc_id for the user is just "user" bc of sign_in not having access to the doc_id
    private struct Listener {
        var doc_id: String
        var listener: any ListenerRegistration
    }
    
    init() {
        self.user = User()
        self.games = []
    }
    
    //Methods that effect both user and game
    //Remove all listeners if any
    func sign_out() {
        user.save_locally()
        for i in 0..<listeners.count {
            listeners[i].listener.remove()
        }
        //Publishing changes from within view updates is not allowed, this will cause undefined behavior.
        //user = User()
        //games = []
        self.user.doc_id = ""
        self.user.username = ""
        self.user.password = ""
        self.user.first_name = ""
        self.user.last_name = ""
        self.user.email = ""
        self.user.game_doc_ids.removeAll()
        self.user.invitations.removeAll()
        self.games.removeAll()
    }
    
    //Delete any data in the database
    //Delete any data stored locally
    func delete_account() {
        print("Deleting acount...")
        //Remove from database
        remove_file(filename: "user.json")
        remove_file(filename: "games.json")
        remove_document(collection: "users", doc_id: user.doc_id)
        //Remove player from all games they are in
        let player = Player(doc_id: user.doc_id, username: user.username)
        for game in games {
            remove_player_from_game(doc_id: game.doc_id, player: player)
        }
        sign_out()
    }
    
    func remove_player_from_game(doc_id: String, player: Player) {
        let encoded_player: [String: Any]
        do {
            // encode the swift struct instance into a dictionary
            // using the Firestore encoder
            encoded_player = try Firestore.Encoder().encode(player)
        } catch {
            // encoding error
            print("remove_player_from_game Error encoding player \(error)")
            return
        }
        let ref = db.collection("games").document(doc_id)
        ref.updateData([
            "players": FieldValue.arrayRemove([encoded_player])
        ]) { err in
            if let err = err {
                print("Error removing player from game: \(err)")
            }
        }
    }
    
    /*
     Remove nosey listener
     Remove game from games array
     Remove game from user.game_doc_ids
     Remove player from game doc in database or delete game if final_player
     Remove game_doc_id from game_doc_ids in database
     Save state of user locally
     */
    func leave_game(doc_id: String, final_player: Bool) {
        print("Leaving game \(doc_id)")
        for i in 0..<listeners.count {
            if (listeners[i].doc_id == doc_id) {
                listeners[i].listener.remove()
                listeners.remove(at: i)
                break
            }
        }
        if let index = games.firstIndex(where: {$0.doc_id == doc_id}) {
            games.remove(at: index)
        } else {
            print("Unable to find doc_id in games array")
        }
        if let index = user.game_doc_ids.firstIndex(where: {$0 == doc_id}) {
            user.game_doc_ids.remove(at: index)
        } else {
            print("Unable to find doc_id in games array")
        }
        if (final_player) {
            db.collection("games").document(doc_id).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
        } else {
            let player = Player(doc_id: user.doc_id, username: user.username)
            remove_player_from_game(doc_id: doc_id, player: player)
            let ref = db.collection("users").document(user.doc_id)
            ref.updateData([
                "game_doc_ids": FieldValue.arrayRemove([doc_id])
            ]) {err in
                if let err = err {
                    print("Error removing game_doc_id from game_doc_ids \(err)")
                }
            }
        }
        user.save_locally()
    }
}

//Methods related to Games
extension PlayerOne {
    //After a user signs in, corresponding User collection is retrieved and set
    //We use all the game_doc_ids from User to retrieve game data from the database
    //Also we set all the games
    func load_games() {
        print("Entering load_games")
        for doc_id in user.game_doc_ids {
            game_listener(game_doc_id: doc_id)
        }
    }
    //Loads game from the database
    //Receives updates to the game from the database
    //Also appends game to games[] array
    func game_listener(game_doc_id doc_id: String) {
        print("Entering add game listener")
        let ref = db.collection("games").document(doc_id)
        let document_snapshot = ref.addSnapshotListener { [self] documentSnapshot, error in
            if let error = error {
                print("Error retriveing the collection \(error)")
                return
            }
            guard let doc = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            if (doc.metadata.hasPendingWrites) {
                print("Wait for local changes to write to database..")
                return
            }
            guard let data = doc.data() else {
                //Means the game does not exist
                print("Document data was empty for id \(doc_id).")
                return
            }
            if var game = Game(game: data) {
                //New game on device probably from calling load_games()
                //In database, doc_ids are "" from when we create the game
                if (game.doc_id == "") {
                    game.doc_id = doc_id
                }
                //Updating an existing game
                for i in 0..<games.count {
                    if (games[i].doc_id == doc_id) {
                        games[i] = game
                        print("game_listener updated game \(doc_id)")
                        return
                    }
                }
                print("game_listener adding new game \(game)")
                games.append(game)
            }
        }
        let listener = Listener(doc_id: doc_id, listener: document_snapshot)
        listeners.append(listener)
    }

}

//Methods related to User
//Each update to database should have respective local write
//TODO: save user state in applicationWillTerminate
//TODO: Differentiate between local and database saves
extension PlayerOne {
    //Finds username and password in database, saves user locally
    //TODO: Firestore authentication this seems very hackable
    func sign_in(_ username: String, _ password: String,
                 _ completion: @escaping ((Bool) -> Void)) {
        print("Entering sign_in")
        db.collection("users").whereField("username", isEqualTo: username).getDocuments() { querySnapshot, error in
            if let error = error {
                print("sign_in Error retriveing the collection \(error)")
                return
            }
            guard let documents = querySnapshot?.documents else {
                print("sign_in Error fetching documents: \(error!)")
                completion(false)
                return
            }
            if (documents.count <= 0) {
                print("sign_in No documents found for \(username)")
                completion(false)
                return
            }
            if var user = User(json: documents[0].data()) {
                if (user.password != password) {
                    print("sign_in incorrect password for \(username)")
                    completion(false)
                } else {
                    if (user.doc_id == "") {
                        user.doc_id = documents[0].documentID
                    }
                    self.user = user
                    user.save_locally()
                    completion(true)
                }
            }
        }
    }
    //Creates a listener for User
    //Receives updates to the User from the database
    //Mostly for listening to invitations
    //Added bonus, checks local data against server
    func user_listener() {
        print("Entering user_listener")
        let ref = db.collection("users").document(self.user.doc_id)
        //let ref = db.collection("users").document(self.user.doc_id)
        let document_snapshot = ref.addSnapshotListener { [self] documentSnapshot, error in
            guard let doc = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            if (doc.metadata.hasPendingWrites) {
                print("User wait for local changes to write to database..")
                return
            }
            guard doc.data() != nil else {
                print("Document data was empty for id: \(user.doc_id), user:\(user.username).")
                return
            }
            if var player = User(json: doc.data()!) {
                if (player.doc_id == "") {
                    player.doc_id = self.user.doc_id
                }
                print("Updating user \(user)")
                self.user = player
                user.save_locally()
            }
        }
        //TODO: If addSnapShotListener fails or cause callback this isn't really initialized, it probably shouldn't be appended to array
        let listener = Listener(doc_id: "user", listener: document_snapshot)
        listeners.append(listener)
        print("Exiting user_listener")
    }
    //Rejecting an invitation involves removing it from local array and updating database with the state
    //Also removes it from the game invitations
    //Used when user accepts an invitation and rejects one
    func delete_invitation(game_doc_id: String) {
        //Remove locally
        for i in 0..<user.invitations.count {
            if (user.invitations[i] == game_doc_id) {
                user.invitations.remove(at: i)
                break
            }
        }
        user.save_locally()
        //Remove from database
        var ref = db.collection("users").document(user.doc_id)
        ref.updateData([
            "invitations": FieldValue.arrayRemove([ game_doc_id ])
        ])
        ref = db.collection("games").document(game_doc_id)
        ref.updateData([
            "invitations": FieldValue.arrayRemove([ game_doc_id ])
        ])
    }
    func update_username(username: String, completion: @escaping ((Bool) -> Void)) {
        print("Updating username in database")
        let user_ref = db.collection("users").document(user.doc_id)
        user_ref.updateData([
            "username": username
        ]) { [self] err in
            if let err = err {
                print("Error updating username: \(err)")
                completion(false)
            } else {
                print("Username successfully updated")
                user.username = username
                user.save_locally()
                completion(true)
            }
        }
    }
    func update_password(password: String, completion: @escaping ((Bool) -> Void)) {
        print("Updating password in database")
        let user_ref = db.collection("users").document(user.doc_id)
        user_ref.updateData([
            "password": password
        ]) { [self] err in
            if let err = err {
                print("Error updating password: \(err)")
                completion(false)
            } else {
                print("Username successfully updated")
                user.password = password
                user.save_locally()
                completion(true)
            }
        }
    }
    func update_first_name(first_name: String, completion: @escaping ((Bool) -> Void)) {
        print("Updating first_name in database")
        let user_ref = db.collection("users").document(user.doc_id)
        user_ref.updateData([
            "first_name": first_name
        ]) { [self] err in
            if let err = err {
                print("Error updating first name: \(err)")
                completion(false)
            } else {
                print("first name successfully updated")
                user.first_name = first_name
                user.save_locally()
                completion(true)
            }
        }
    }
    func update_last_name(last_name: String, completion: @escaping ((Bool) -> Void)) {
        print("Updating last_name in database")
        let user_ref = db.collection("users").document(user.doc_id)
        user_ref.updateData([
            "last_name": last_name
        ]) { [self] err in
            if let err = err {
                print("Error updating last name: \(err)")
                completion(false)
            } else {
                print("last name successfully updated")
                user.last_name = last_name
                user.save_locally()
                completion(true)
            }
        }
    }
    func update_email(email: String, completion: @escaping ((Bool) -> Void)) {
        print("Updating email in database")
        let user_ref = db.collection("users").document(user.doc_id)
        user_ref.updateData([
            "email": email
        ]) { [self] err in
            if let err = err {
                print("Error updating email: \(err)")
                completion(false)
            } else {
                print("last name successfully updated")
                user.email = email
                user.save_locally()
                completion(true)
            }
        }
    }
    //When player creates a new game add game_doc_id to player doc
    func add_game_doc_id(game_doc_id: String, completion: @escaping ((Bool) -> Void)) {
        //Upload doc_id to user data stored in cloud
        print("Entering game_doc_id")
        db.collection("users").document(user.doc_id).updateData([
            "game_doc_ids": FieldValue.arrayUnion([game_doc_id])
        ]) { [self] err in
            if let err = err {
                print("Failed to add game_doc_id to user in database \(err)")
                completion(false)
            } else {
                print("Successfully added game_doc_id to user in database")
                user.game_doc_ids.append(game_doc_id)
                user.save_locally()
                completion(true)
            }
        }
    }
}

//For writing user data to the Documents directory
func write_json(filename: String, data: Data) -> Bool {
    print("Entering write_json")
    //Get file location
    var file: URL
    do {
        file = try FileManager.default.url(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(filename, conformingTo: .json)
    } catch {
        print("Unable to create path in documents for \(filename) \(error)")
        return false
    }
    //Write data
    do {
        try data.write(to: file)
    } catch {
        print("Failed to write \(filename) data \(data) \(error)")
        return false
    }
    return true
}

//So then we don't have to do that extra steps in read_user
func read_json(filename: String) -> Any? {
    print("Entering read_json")
    //Get filepath
    var file: URL
    do {
        file = try FileManager.default.url(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(filename, conformingTo: .json)
    } catch {
        print("Unable to create path in documents for \(filename) \(error)")
        return nil
    }
    //Create a file descriptor
    var file_handle: FileHandle
    do {
        file_handle = try FileHandle(forReadingFrom: file)
    } catch let error as NSError {
        print("Unable to create FileHandle for \(filename) \(error)")
        return nil;
    }
    //Read in bytes from file
    var data: Data?
    do {
        data = try file_handle.readToEnd()
    } catch {
        print("Unable to read \(filename) \(error)")
        return nil;
    }
    //Ensure data is returned
    if(data == nil) {
        print("\(filename) Filehandler returned nil")
        return nil
    }
    //Ensure json can be interpreted
    var json_data: Any
    do {
        json_data = try JSONSerialization.jsonObject(with: data!)
    } catch {
        print("Unable to parse JSON \(filename) \(error)")
        return nil
    }
    return json_data
}

//Called when a user deletes their account
func remove_file(filename: String) {
    print("Entering remove_file")
    var file: URL
    do {
        file = try FileManager.default.url(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(filename, conformingTo: .json)
    } catch {
        print("Unable to create path in documents for \(filename) \(error)")
        return
    }
    do {
        try FileManager.default.removeItem(at: file)
    } catch {
        print("Failed to remove \(filename) \(error)")
    }
}

func remove_document(collection: String, doc_id: String) {
    print("Entering remove_document")
    db.collection(collection).document(doc_id).delete() { err in
        if let err = err {
            print("Error removing document for collection \(collection): \(err)")
        } else {
            print("Document successfully removed from \(collection)!")
        }
    }
}

//Used in views that perform some async task
//Updating is convienent to display ProgressView
//msg is successfull to communicate result from async task to user
//Success used to display text in green if successful, red if unsuccessfull
struct Status {
    var msg: String = ""
    var updating: Bool = false
    var success: Bool = false
    
    mutating func set(msg: String, updating: Bool, success: Bool) {
        self.msg = msg
        self.updating = updating
        self.success = success
    }
    
    mutating func reset() {
        self.msg = ""
        self.updating = false
        self.success = false
    }
}
