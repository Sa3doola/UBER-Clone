//
//  PickupVC.swift
//  Uber-Clone
//
//  Created by Saad Sherif on 1/29/21.
//

import UIKit
import MapKit

protocol PickupVCDelegate: class {
    func didAcceptTrip(_ trip: Trip)
}

class PickupVC: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: PickupVCDelegate?
    private let mapView = MKMapView()
    let trip: Trip
    
    private let cancelButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "baseline_clear_white_36pt_2x").withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
        return btn
    }()
    
    private let pickupLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Would you like to pickup tthis passenger?"
        lbl.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        lbl.textColor = .white
        return lbl
    }()
    
    private let acceptTripButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .white
        btn.setTitle("ACCEPT TRIP", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        btn.addTarget(self, action: #selector(handleAcceptTrip), for: .touchUpInside)
        return btn
    }()
    
    // MARK: - LifeCycle
    
    init(trip: Trip) {
        self.trip = trip
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMapView()
        configureUI()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Selectors
    
    @objc func handleDismissal() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleAcceptTrip() {
        Service.shared.acceptTrip(trip: trip) { (error, ref) in
            self.delegate?.didAcceptTrip(self.trip)
        }
    }
    
    // MARK: - Helper Functions
    
    func configureMapView() {
        let region = MKCoordinateRegion(center: trip.pickupCoordinates, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
        
        mapView.addAnnotaionAndSelect(forCoordinate: trip.pickupCoordinates)
    }
    
    func configureUI() {
        view.backgroundColor = .backgroundColor
        
        view.addSubview(cancelButton)
        cancelButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor,
                            paddingTop: 10, paddingLeft: 16)
        
        view.addSubview(mapView)
        mapView.setDimensions(height: 260, width: 260)
        mapView.layer.cornerRadius = 130
        mapView.centerX(inView: view)
        mapView.centerY(inView: view, constant: -64)
        
        view.addSubview(pickupLabel)
        pickupLabel.centerX(inView: view)
        pickupLabel.anchor(top: mapView.bottomAnchor, paddingTop: 16)
        
        view.addSubview(acceptTripButton)
        acceptTripButton.anchor(top: pickupLabel.bottomAnchor, left: view.leftAnchor,
                            right: view.rightAnchor, paddingTop: 10, paddingLeft: 32,
                            paddingRight: 32, height: 50)
        acceptTripButton.layer.cornerRadius = 12
    }
    
    // MARK: - API
    
    
}
