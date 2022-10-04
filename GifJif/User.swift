//
//  User.swift
//  GifJif
//
//  Created by Tommy Smale on 9/18/22.
//

import Foundation
import FirebaseFirestore

var device_owner = get_self() ?? User()

//Return username of user
//To handle ID: Do not let user create game unless they have an account
class User: Identifiable, Codable {
    let id: UUID
    let doc_id: String
    var username: String
    var password: String
    var first_name: String
    var last_name: String
    var email: String
    var games: [Game] = []
}

//When a user does not have an account
//Useful for storing their games
extension User {
    init() {
        self.id = UUID()
        self.doc_id = ""
        self.username = ""
        self.password = ""
        self.first_name = ""
        self.last_name = ""
        self.email = ""
    }
}

//Original purpose for making struct out of CreateAccount form data and the docid generated after saving user data to the database
extension User {
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

    }
}

//Used for initializing device owner
extension User {
    init?(json: [String: Any]) {
        //Verify all of the types
        guard let doc_id = json["doc_id"] as? String,
              let username = json["username"] as? String,
              let password = json["password"] as? String,
              let first_name = json["first_name"] as? String,
              let last_name = json["last_name"] as? String,
              let email = json["email"] as? String
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
    }
}

//Used for initializing player retrieved from database
//TODO: See if there are any optional parameters, delete this duplicated code
extension User {
    init?(doc_id: String, json: [String: Any]) {
        //Verify all of the types
        guard let username = json["username"] as? String,
              let password = json["password"] as? String,
              let first_name = json["first_name"] as? String,
              let last_name = json["last_name"] as? String,
              let email = json["email"] as? String
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

//A wrapper for save_user_locally for when a user is signing into their account
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

//This is the owner of the device
//This retrives their account settings
func get_self() -> User? {
    //Get filepath
    var file: URL
    do {
        file = try FileManager.default.url(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("user.json", conformingTo: .json)
    } catch {
        print("Unable to create path in documents for user.json \(error)")
        return nil
    }
    
    //Create a file descriptor
    var file_handle: FileHandle
    do {
        file_handle = try FileHandle(forReadingFrom: file)
    } catch let error as NSError {
        print("Unable to create FileHandle for \(file.absoluteString) \(error)")
        return nil;
    }
    
    //Read in bytes from file
    var data: Data?
    do {
        data = try file_handle.readToEnd()
    } catch {
        print("Unable to read categories.txt \(error)")
        return nil;
    }
    
    if(data == nil) {
        print("\(file) Filehandler returned nil")
        return nil
    }
    
    var json_data: Any
    do {
        json_data = try JSONSerialization.jsonObject(with: data!)
    } catch {
        print("Unable to parse JSON \(file.absoluteString) \(error)")
        return nil
    }

    if (json_data as? [String: Any] == nil) {
        print("Data read from file not acceptable")
        return nil
    }
    
    return User(json: json_data as! [String: Any])
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
        /*
        .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents \(err)")
                user = nil
            } else {
                if (querySnapshot!.documents.isEmpty) {
                    user = nil
                } else {
                    let doc = querySnapshot!.documents[0]
                    print("Read user w/ id \(doc.documentID) and data \(doc.data())")
                    user = User(doc_id: doc.documentID, data: doc.data())
                    print("player: \(String(describing: user))")
                }
                
            }
        }
         */
    print("user: \(String(describing: user))")
    return user
}

func sign_in(_ username: String, _ password: String) async -> Bool {
    do {
        let querySnapshot = try await db.collection("users").whereField("username", isEqualTo: username).whereField("password", isEqualTo: password).getDocuments()
        if (querySnapshot.documents.isEmpty) {
            return false
        }
        let doc = querySnapshot.documents[0]
        if(save_user_locally(doc_id: doc.documentID, data: doc.data())) {
            print("Successfully saved user data!")
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
