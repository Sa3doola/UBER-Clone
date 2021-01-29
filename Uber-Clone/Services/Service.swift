//
//  Services.swift
//  Uber-Clone
//
//  Created by Saad Sherif on 1/24/21.
//

import UIKit
import CoreLocation
import Firebase

struct Service {
    
    static let shared = Service()
    
    func uploadTrip(_ pickupCoordinates: CLLocationCoordinate2D, _ destinationCoordinate: CLLocationCoordinate2D, completion: @escaping (Error?, DatabaseReference) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let pickupArray = [pickupCoordinates.latitude, pickupCoordinates.longitude]
        let destinationArray = [destinationCoordinate.latitude, destinationCoordinate.longitude]
        
        let values = ["pickupCoordinates": pickupArray,
                      "destinationCoordinates": destinationArray,
                      "state": TripState.requested.rawValue] as [String: Any]
        
        REF_TRIPS.child(uid).updateChildValues(values, withCompletionBlock: completion)
        
    }
    
    func observeTrips(completion: @escaping (Trip) -> Void) {
        REF_TRIPS.observe(.childAdded) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            let uid = snapshot.key
            let trip = Trip(passengerUid: uid, dictionary: dictionary)
            completion(trip)
        }
    }
    
    func acceptTrip(trip: Trip, completion: @escaping (Error?, DatabaseReference) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let values = ["driverUid": uid,
                      "state": TripState.accepted.rawValue] as [String: Any]
        
        REF_TRIPS.child(trip.passengerUid).updateChildValues(values, withCompletionBlock: completion)
    }
    
    func observeCurrentTrip(completion: @escaping (Trip) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        REF_TRIPS.child(uid).observe(.value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            let uid = snapshot.key
            let trip = Trip(passengerUid: uid, dictionary: dictionary)
            completion(trip)
        }
    }
    
}
