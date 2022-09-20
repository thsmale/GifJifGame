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
struct User: Identifiable, Codable {
    let id: UUID
    let doc_id: String
    var username: String
    var password: String
    var first_name: String
    var last_name: String
    var email: String
    //var games: [Game] = []
}

//TODO: handle error if optional not found
extension User {
    init?(doc_id: String, data: Dictionary<String, String>) {
        self.id = UUID()
        self.doc_id = doc_id
        if let username = data["username"] {
            self.username = username
        } else {
            print("User init cannot find username in dict")
            return nil
        }
        if let password = data["password"] {
            self.password = password
        } else {
            print("User init cannot find password in dict")
            return nil
        }
        first_name = data["first_name"] ?? ""
        last_name = data["last_name"] ?? ""
        email = data["email"] ?? ""
    }
}

//TODO: return different error to user if issue with network than if username is taken
func available_username(username: String) -> Bool {
    var ret: Bool = true
    let doc_ref = db.collection("users").whereField("username", isEqualTo: username)
    doc_ref.getDocuments() { (query_snapshot, err) in
        if let err = err {
            print("Query failed \(err)")
            ret = false
        } else {
            if (!query_snapshot!.isEmpty) {
                ret = false
            }
            if (query_snapshot!.count > 0) {
                ret = false
            }
        }
    }
    return ret
}

//This will try to add a user to the database
func add_user(user_data: inout Dictionary<String, String>) -> Bool {
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
        user_data["doc_id"] = ref!.documentID
        if (save_user_locally(data: user_data)) {
            print("Successfully created user.json file")
        }else {
            print("Failed to create user.json file")
        }
    }
    return ret
}
 
func save_user_locally(data: Dictionary<String, String>) -> Bool {
    var data_json: Data
    do {
        data_json = try JSONEncoder().encode(data)
    } catch {
        print("Error encoding user dict to json \(error)")
        return false
    }
    print("type: \(type(of: data_json))")
    print("Save this: " + String(data: data_json, encoding: .utf8)!)
    
    //Get file location
    var file: URL
    do {
        file = try FileManager.default.url(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("user.json", conformingTo: .json)
    } catch {
        print("Unable to create path in documents for user.json \(error)")
        return false
    }
    
    do {
        try data_json.write(to: file)
    } catch {
        print("User write failed \(error)")
        return false
    }
    
    return true
}

func read_user_file() -> Bool {
    //Get filepath
    var file: URL
    do {
        file = try FileManager.default.url(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("user.json", conformingTo: .json)
    } catch {
        print("Unable to create path in documents for user.json \(error)")
        return false
    }
    
    //Create a file descriptor
    var file_handle: FileHandle
    do {
        file_handle = try FileHandle(forReadingFrom: file)
    } catch let error as NSError {
        print("Unable to create FileHandle for \(file.absoluteString) \(error)")
        return false;
    }
    
    //Read in bytes from file
    var data: Data?
    do {
        data = try file_handle.readToEnd()
    } catch {
        print("Unable to read categories.txt \(error)")
        return false;
    }
    
    if(data == nil) {
        print("\(file) Filehandler returned nil")
        return false
    }
    
    var json_data: Any
    do {
        json_data = try JSONSerialization.jsonObject(with: data!)
    } catch {
        print("Unable to parse JSON \(file.absoluteString) \(error)")
        return false
    }
    
    print("User read from file!")
    print(json_data)
    print(type(of: json_data))

    return true
}
