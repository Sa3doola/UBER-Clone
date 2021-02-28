//
//  User.swift
//  Uber-Clone
//
//  Created by Saad Sherif on 1/12/21.
//

import CoreLocation

enum AccountType: Int {
    case passenger
    case driver
}

struct User {
    
    let fullName: String
    let email: String
    var accountType: AccountType!
    let uid: String
    var location: CLLocation?
    var homeLocation: String?
    var workLocation: String?
    
    var firstInitial: String { return String(fullName.prefix(1)) }
    
    init(uid: String, dicationary: [String: Any]) {
        self.uid = uid
        self.fullName = dicationary["FullName"] as? String ?? ""
        self.email = dicationary["email"] as? String ?? ""
        
        if let home = dicationary["HomeLocation"] as? String {
            self.homeLocation = home
        }
        
        if let work = dicationary["WorkLocation"] as? String {
            self.workLocation = work
        }
        
        if let index = dicationary["accountType"] as? Int {
            self.accountType = AccountType(rawValue: index)
        }
    }
}
