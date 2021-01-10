//
//  ViewController.swift
//  Uber-Clone
//
//  Created by Saad Sherif on 1/7/21.
//

import UIKit
import Firebase
import MapKit

private let reuseIdentifier = "LocationCell"

class HomeVC: UIViewController {
    
    // MARK: - Properties
    
    private let mapView = MKMapView()
    
    private let inputActivationView = LocationInputActivationView()
    private let locationInputView = LocationInputView()
    private let tableView = UITableView()
    
    
    // MARK: - LifeCycel
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMapView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkIfAuthenticated()
    }
    
    // MARK: - Selectors
    
    
    // MARK: - Helper Functions
    func configureMapView() {
        view.addSubview(mapView)
        mapView.frame = view.frame
    }
    
    func checkIfAuthenticated() {
        if Auth.auth().currentUser == nil {
            let vc = LoginVC()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false, completion: nil)
        }
    }
    
    func logOut() {
        AuthManager.shared.logOut { (success) in
            DispatchQueue.main.async {
                if success {
                    let vc = LoginVC()
                    let nav = UINavigationController(rootViewController: vc)
                    nav.modalPresentationStyle = .fullScreen
                    self.present(nav, animated: false, completion: nil)
                }
            }
        }
    }
    
}

