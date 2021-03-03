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
    
    private lazy var circularProgressView: CircularProgressView = {
        let frame = CGRect(x: 0, y: 0, width: 360, height: 360)
        let cp = CircularProgressView(frame: frame)
        
        cp.addSubview(mapView)
        mapView.setDimensions(height: 268, width: 268)
        mapView.layer.cornerRadius = 268 / 2
        mapView.centerX(inView: cp)
        mapView.centerY(inView: cp, constant: 32)
        
        return cp
    }()
    
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
        self.perform(#selector(animateProgress), with: nil, afterDelay: 0.5)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Selectors
    
    @objc func handleDismissal() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func animateProgress() {
        circularProgressView.animatePulsatingLayer()
        circularProgressView.setProgressWithAnimation(duration: 7, value: 0) {
            guard let state = self.trip.state else { return }
            if state == .denied  {
                DriverService.shared.updateTripState(trip: self.trip, state: .denied) { (err, ref) in
                    self.dismiss(animated: true, completion: nil)
                }
            } else { return }
        }
    }
    
    @objc func handleAcceptTrip() {
        DriverService.shared.acceptTrip(trip: trip) { (error, ref) in
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
        
        view.addSubview(circularProgressView)
        circularProgressView.setDimensions(height: 360, width: 360)
        circularProgressView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        circularProgressView.centerX(inView: view)
        
        view.addSubview(pickupLabel)
        pickupLabel.centerX(inView: view)
        pickupLabel.anchor(top: circularProgressView.bottomAnchor, paddingTop: 32)
        
        view.addSubview(acceptTripButton)
        acceptTripButton.anchor(top: pickupLabel.bottomAnchor, left: view.leftAnchor,
                            right: view.rightAnchor, paddingTop: 10, paddingLeft: 32,
                            paddingRight: 32, height: 50)
        acceptTripButton.layer.cornerRadius = 12
    }
}
