//
//  User.swift
//  GifJif
//
//  Created by Tommy Smale on 9/18/22.
//

import Foundation
import FirebaseFirestore

//Return username of user
struct User: Identifiable {
    let id = UUID()
    var username: String
    var password: String
    var first_name: String = ""
    var last_name: String = ""
    var email: String = ""
    //var games: [Game] = []
}

func get_user() -> User {
    let user: User = User(username: "tommy", password: "secret")
    return user
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
            if (query_snapshot!.documents.count > 0) {
                ret = false
            }
        }
    }
    return ret
}

func add_user(user: User) -> Bool {
    var ret: Bool = true
    var ref: DocumentReference? = nil
    let x = [
        "username": user.username,
        "password": user.password
    ]
    ref = db.collection("users").addDocument(data: ["user": x]) { err in
        if let err = err {
            print("Error adding document: \(err)")
            ret = false
        } else {
            print("Document added with id \(ref!.documentID)")
        }
    }
    return ret
}
