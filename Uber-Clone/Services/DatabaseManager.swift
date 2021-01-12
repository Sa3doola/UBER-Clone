//
//  DatabaseManager.swift
//  Uber-Clone
//
//  Created by Saad Sherif on 1/9/21.
//

import UIKit
import Firebase

let DB_REF = Database.database().reference()
let REF_USERS = DB_REF.child("Users")

public class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    let currentUid = Auth.auth().currentUser?.uid
    
    public func insertNewUser(values: [String: Any], uid: String) {
        DB_REF.child("Users").child(uid).setValue(values) { (error, ref) in
            if let error = error {
                print("Failed to save data to realTime database with error \(error.localizedDescription)")
                return
            }
            print("Successfully saved data to database")
        }
    }
    
     func fetchUserData(completion: @escaping(User) -> Void) {
        
        guard let currentUId = Auth.auth().currentUser?.uid else { return }
        
        REF_USERS.child(currentUId).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            let user = User(dicationary: dictionary)
            
            completion(user)
        }
    }
}
