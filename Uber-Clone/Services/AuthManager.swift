//
//  AuthManager.swift
//  Uber-Clone
//
//  Created by Saad Sherif on 1/9/21.
//

import UIKit
import FirebaseAuth

public class AuthManager {
    
    static let shared = AuthManager()
    
    let database = DatabaseManager()
    
    public func createUser(email: String, password: String, fullname: String, accountTypeIndex: Int, completion: @escaping (_ success: Bool) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (result, error) in
            guard let stongSelf = self else { return }
            if let error = error {
                print("Failed to register user with error \(error.localizedDescription)")
                completion(false)
            }
            
            guard let uid = result?.user.uid else { return }
            
            let values = ["email": email,
                          "FullName": fullname,
                          "accountType": accountTypeIndex] as [String: Any]
            
            stongSelf.database.insertNewUser(values: values, uid: uid)
            completion(true)
        }
    }
    
    public func logIn(email: String, password: String,
                      completion: @escaping (_ success: Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            
        }
    }
    
    public func logOut(completion: (Bool) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(true)
            return
        } catch let error {
            print("Failed to log out with error \(error.localizedDescription)")
            completion(false)
            return
        }
    }
}
