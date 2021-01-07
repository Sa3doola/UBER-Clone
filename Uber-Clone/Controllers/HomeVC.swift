//
//  ViewController.swift
//  Uber-Clone
//
//  Created by Saad Sherif on 1/7/21.
//

import UIKit
import MapKit
import Foundation

class HomeVC: UIViewController {
    
    // MARK: - Properties
    
    private let mapView = MKMapView()
    
    
    // MARK: - LifeCycel
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMapView()
    }
    
    
    // MARK: - Selectors
    
    
    // MARK: - Helper Functions
    func configureMapView() {
        view.addSubview(mapView)
        mapView.frame = view.frame
    }
    
    // MARK: - Properties

    


}

