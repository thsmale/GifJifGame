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
    
    //Reads the local games saved to the device
    //TODO: Handle game that was deleted
    func read_games() {
        print("Entering read games")
        if let game_data = read_json(filename: "games.json") as? [[String: Any]] {
            for game in game_data {
                if let g = Game(game: game) {
                    if (add_listener(game_doc_id: g.doc_id)) {
                        games.append(g)
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
        for doc_id in user.game_doc_ids {
            if (add_listener(game_doc_id: doc_id)) {
                print("Failed to add game \(doc_id)")
            }
        }
        if (write_games(games: games)) {
            print("Successfully saved games locally")
        } else {
            print("Failed to save games locally")
        }
        print("Exiting load games")
    }
    
    //Receives updates to the game from the database
    func add_listener(game_doc_id doc_id: String) -> Bool  {
        print("Entering add listener")
        var ret = true
        let ref = db.collection("games").document(doc_id)
        ref.addSnapshotListener { [self] documentSnapshot, error in
            guard let doc = documentSnapshot else {
              print("Error fetching document: \(error!)")
                ret = false
              return
            }
            guard doc.data() != nil else {
              print("Document data was empty for \(doc_id).")
                ret = false
              return
            }
            if let game = Game(game: doc.data()!) {
                //Updating an existing game
                for i in 0...games.count {
                    if (games[i].doc_id == doc_id) {
                        games[i] = game
                        return
                    }
                }
                //New game on device
                games.append(game)
            }
        }
        print("Exiting add listener")
        return ret
    }
}

//Functions related to User
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
    func sign_in(_ username: String, _ password: String) -> Bool {
        print("Entering sign_in")
        var ret = true
        db.collection("users").whereField("username", isEqualTo: username)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    ret = false
                    return
                }
                if (documents.count <= 0) {
                    print("No documents found for \(username)")
                    ret = false
                    return
                }
                if let user = User(json: documents[0].data()) {
                    print ("Sign in successful")
                    self.user = user
                }
            }
        print ("Exiting sign_in w status \(ret)")
        return ret
    }
    //Creates a listener for User
    //Receives updates to the User from the database
    //Mostly for listening to invitations
    //Added bonus, checks local data against server
    func user_listener() {
        print("Entering user_listener")
        let ref = db.collection("users").document(self.user.doc_id)
        ref.addSnapshotListener { [self] documentSnapshot, error in
            guard let doc = documentSnapshot else {
              print("Error fetching document: \(error!)")
              return
            }
            guard doc.data() != nil else {
                print("Document data was empty for \(user.doc_id) \(user.username).")
              return
            }
            if let player = User(json: doc.data()!) {
                print("Updating user")
                self.user = player
            }
        }
        print("Exiting user_listener")
    }
}

//For writing user data to the Documents directory
func write_json(filename: String, data: Data) -> Bool {
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


