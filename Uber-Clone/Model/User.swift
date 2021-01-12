//
//  User.swift
//  Uber-Clone
//
//  Created by Saad Sherif on 1/12/21.
//

struct User {
    
    let fullName: String
    let email: String
    let accountType: Int
    
    init(dicationary: [String: Any]) {
        self.fullName = dicationary["FullName"] as? String ?? ""
        self.email = dicationary["email"] as? String ?? ""
        self.accountType = dicationary["accountType"] as? Int ?? 0
    }
    
}
