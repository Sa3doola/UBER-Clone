//
//  User.swift
//  Uber-Clone
//
//  Created by Saad Sherif on 1/12/21.
//

import CoreLocation

struct User {
    
    let fullName: String
    let email: String
    let accountType: Int
    let uid: String
    var location: CLLocation?
    
    init(uid: String, dicationary: [String: Any]) {
        self.uid = uid
        self.fullName = dicationary["FullName"] as? String ?? ""
        self.email = dicationary["email"] as? String ?? ""
        self.accountType = dicationary["accountType"] as? Int ?? 0
    }
    
}
