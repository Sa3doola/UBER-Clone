//
//  AuthManager.swift
//  Uber-Clone
//
//  Created by Saad Sherif on 1/9/21.
//

import UIKit
import Firebase
import GeoFire

public class AuthManager {
    
    static let shared = AuthManager()
    
    var location = LocationHandler.shared.locationManager.location
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
            
            if accountTypeIndex == 1 {
                let geofire = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)
                guard let location = stongSelf.location else { return }
                
                geofire.setLocation(location, forKey: uid) { (error) in
                    if error != nil {
                        print("Set Location Error with \(String(describing: error?.localizedDescription))")
                        return
                    }
                    stongSelf.database.insertNewUser(values: values, uid: uid)
                    completion(true)
                    return
                }
            }
            
            stongSelf.database.insertNewUser(values: values, uid: uid)
            completion(true)
        }
    }
    
    public func logIn(email: String, password: String, completion: @escaping (_ success: Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print("Failed to log in with error \(error.localizedDescription)")
                completion(false)
                return
            }
            print("Successfully logged in ....")
            completion(true)
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
