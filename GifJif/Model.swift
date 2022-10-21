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


class PlayerOne: ObservableObject {
    @Published var user: User
    @Published var games: [Game]
    private var user_listeners: [DocumentSnapshot] = []
    
    init() {
        user = read_user()
        games = read_games()
    }
    
    func sign_out() {
        user = User()
        games = []
    }
    
    //After a user signs in, we use all the game_doc_ids to retrieve game data from the database
    func load_games() {
        print("Entering load_games")
        for doc_id in user.game_doc_ids {
            let doc_ref = db.collection("games").document(doc_id)
            doc_ref.getDocument { (document, error) in
                if let document = document, document.exists {
                    if (document.data() == nil) {
                        print("Doucment is empty \(String(describing: error))")
                        return
                    }
                    if let game = Game(game: document.data()!) {
                        self.games.append(game)
                        print("Adding listener to \(game)")
                        doc_ref.addSnapshotListener { documentSnapshot, error in
                            guard let doc = documentSnapshot else {
                              print("Error fetching document: \(error!)")
                              return
                            }
                            guard let data = doc.data() else {
                              print("Document data was empty.")
                              return
                            }
                            if (error == nil) {
                                print(data)
                            } else {
                                print("addSnapshotListener error \(String(describing: error))")
                            }
                        }
                    }
                }
                if (error != nil) {
                    print("Error getting game \(String(describing: error)) from \(doc_id)")
                }
            }
        }
        if (write_games(games: games)) {
            print("Successfully saved games locally")
        } else {
            print("Failed to save games locally")
        }
    }
    
    func add_listeners() {
        print("Adding listeners")
        for doc_id in user.game_doc_ids {
             db.collection("users").document(doc_id)
                .addSnapshotListener { documentSnapshot, error in
                    guard let document = documentSnapshot else {
                        print("Err fetching document \(String(describing: error))")
                        return
                    }
                    if (error == nil) {
                        print(document.data())
                        self.user_listeners.append(document)
                    } else {
                        print("add_listeners error \(String(describing: error))")
                    }
                }
        }
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

func read_json(filename: String) -> Any? {
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

