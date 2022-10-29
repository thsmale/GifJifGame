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

class PlayerOne: ObservableObject {
    @Published var user: User
    @Published var games: [Game]
    
    //TODO: Remove listeners
    
    init() {
        self.user = User()
        self.games = []
    }
    
    func sign_out() {
        //Publishing changes from within view updates is not allowed, this will cause undefined behavior.
        user = User()
        games = []
    }
}

//Methods related to Games
extension PlayerOne {
    //Reads the local games saved to the device
    //TODO: Handle game that was deleted
    func read_games() {
        print("Entering read games")
        if let game_data = read_json(filename: "games.json") as? [[String: Any]] {
            for game in game_data {
                if let g = Game(game: game) {
                    add_listener(game_doc_id: g.doc_id) { success in
                        if (success) {
                            print("read_games added listener for \(g.doc_id)")
                        } else {
                            print("read_games failed to add listener for \(g.doc_id)")
                        }
                    }
                }
            }
        } else {
            print("Unable to cast games.json to [[String: Any]]")
        }
        print("Exiting read games")
    }
    
    //After a user signs in, corresponding User collection is retrieved and set
    //We use all the game_doc_ids from User to retrieve game data from the database
    //Also we set all the games
    func load_games() {
        print("Entering load_games")
        let group = DispatchGroup()
        for doc_id in user.game_doc_ids {
            group.enter()
            add_listener(game_doc_id: doc_id) { success in
                if (success) {
                    print("load_games added listener for game \(doc_id)")
                } else {
                    print("load_games failed to add listener for game \(doc_id)")
                }
                group.leave()
            }
        }
        //Waits for entire for loop to complete before saving games
        group.notify(queue:.main) {
            if (write_games(games: self.games)) {
                print("Successfully saved games locally")
            } else {
                print("Failed to save games locally")
            }
        }
        print("Exiting load games")
    }
    
    //Loads game from the database
    //Receives updates to the game from the database
    //Also appends game to games[] array
    func add_listener(game_doc_id doc_id: String, completion: @escaping ((Bool) -> Void)) {
        print("Entering add game listener")
        let ref = db.collection("games").document(doc_id)
        ref.addSnapshotListener { [self] documentSnapshot, error in
            print("game snapshot listener")
            guard let doc = documentSnapshot else {
                print("Error fetching document: \(error!)")
                completion(false)
                return
            }
            if (doc.metadata.hasPendingWrites) {
                print("Wait for local changes to write to database..")
                completion(false)
                return
            }
            guard doc.data() != nil else {
                print("Document data was empty for id \(doc_id).")
                completion(false)
                return
            }
            if let game = Game(game: doc.data()!) {
                //Updating an existing game
                for i in 0..<games.count {
                    if (games[i].doc_id == doc_id) {
                        games[i] = game
                        print("add_listener updated game \(game)")
                        completion(true)
                        return
                    }
                }
                //New game on device
                print("add_listener adding new game \(game)")
                games.append(game)
                completion(true)
            }
        }
        print("Exiting add listener")
    }
}

//Methods related to User
extension PlayerOne {
    //This will try to add a user to the database
    //Called when user creates an account
    //TODO: Val of doc_id in database will be ""
    func create_account(user: inout User) -> Bool {
        print("Entering create account")
        let ref = db.collection("users").document()
        do {
            try ref.setData(from: user)
            user.doc_id = ref.documentID
            self.user = user
            print("User \(user.username) successfully added to database")
            return true
        } catch let error {
            print("Error writing game to firestore \(error)")
            return false
        }
    }
    //Finds username and password in database, saves user locally
    func sign_in(_ username: String, _ password: String,
                 _ completion: @escaping ((Bool) -> Void)) {
        print("Entering sign_in")
        db.collection("users").whereField("username", isEqualTo: username)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    completion(false)
                    return
                }
                if (documents.count <= 0) {
                    print("No documents found for \(username)")
                    completion(false)
                    return
                }
                if let user = User(json: documents[0].data()) {
                    print ("Sign in successful")
                    self.user = user
                    completion(true)
                }
            }
        print("Exiting sign_in")
    }
    //Creates a listener for User
    //Receives updates to the User from the database
    //Mostly for listening to invitations
    //Added bonus, checks local data against server
    func user_listener() {
        print("Entering user_listener")
        let ref = db.collection("users").document(self.user.doc_id)
        //let ref = db.collection("users").document(self.user.doc_id)
        ref.addSnapshotListener { [self] documentSnapshot, error in
            guard let doc = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            guard doc.data() != nil else {
                print("Document data was empty for id: \(user.doc_id), user:\(user.username).")
                return
            }
            if let player = User(json: doc.data()!) {
                print("Updating user")
                self.user = player
            }
        }
        print("Exiting user_listener")
    }
    //Rejecting an invitation involves removing it from local array and updating database with the state
    //Used when user accepts an invitation and rejects one
    func delete_invitation(game_doc_id: String) {
        //Remove locally
        for i in 0..<user.invitations.count {
            if (user.invitations[i] == game_doc_id) {
                user.invitations.remove(at: i)
                break
            }
        }
        //Remove from database
        let ref = db.collection("users").document(user.doc_id)
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
                completion(true)
            }
        }
    }}

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


