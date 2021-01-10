//
//  DatabaseManager.swift
//  Uber-Clone
//
//  Created by Saad Sherif on 1/9/21.
//

import UIKit
import FirebaseDatabase

public class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
    public func insertNewUser(values: [String: Any], uid: String) {
        database.child("Users").child(uid).setValue(values) { (error, ref) in
            if let error = error {
                print("Failed to save data to realTime database with error \(error.localizedDescription)")
                return
            }
            print("Successfully saved data to database")
        }
    }
}
