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


class Player: ObservableObject {
    @Published var user: User
    @Published var games: [Game]
    
    init() {
        user = read_user()
        games = read_games()
    }
    
    func sign_out() {
        user = User()
        games = []
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

//TODO: handle data not saving
func sign_in(_ username: String, _ password: String) async -> Bool {
    do {
        let querySnapshot = try await db.collection("users").whereField("username", isEqualTo: username).whereField("password", isEqualTo: password).getDocuments()
        if (querySnapshot.documents.isEmpty) {
            return false
        }
        let doc = querySnapshot.documents[0]
        if(save_user_locally(doc_id: doc.documentID, data: doc.data())) {
            //device_owner = User(doc_id: doc.documentID, data: doc.data()) ?? User()
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
