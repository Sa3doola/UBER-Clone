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
private let annotationIdentifire = "DriverAnnotation"

private enum actionButtonConfiguration {
    case showMenu
    case dismissActionView
    
    init() {
        self = .showMenu
    }
}

class HomeVC: UIViewController {
    
    // MARK: - Properties
    
    private let mapView = MKMapView()
    private let locationManager = LocationHandler.shared.locationManager
    
    private let inputActivationView = LocationInputActivationView()
    private let locationInputView = LocationInputView()
    private let rideActionView = RideActionView()
    private let tableView = UITableView()
    private var searchResult = [MKPlacemark]()
    private final let locationInputViewHeight: CGFloat = 200
    private final let rideActionViewHeight: CGFloat = 300
    private var actionBtnConfig = actionButtonConfiguration()
    private var route: MKRoute?

    private var user: User? {
        didSet {
            locationInputView.user = user
            
            if user?.accountType == .passenger {
                fetchDriverData()
                configureLocationInputActivationView()
                observeCurrentTrip()
            } else {
                observeTrips()
            }
        }
    }
    
    private var trip: Trip? {
        didSet {
            guard let user = user else { return }
            
            if user.accountType == .driver {
                guard let trip = trip else { return }
                let vc = PickupVC(trip: trip)
                vc.delegate = self
                self.present(vc, animated: true, completion: nil)
            } else {
                print("DEBUG: show ride action view for accepted trip..")
            }
        }
    }
    
    private let actionbutton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        return btn
    }()
        
    // MARK: - LifeCycel
    override func viewDidLoad() {
        super.viewDidLoad()
        enableLocationServices()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkIfAuthenticated()
    }
    
    // MARK: - Selectors
    @objc func actionButtonPressed() {
        switch actionBtnConfig {
        case .showMenu:
            print("DEBUG: Handle show menu..")
        case .dismissActionView:
            removeAnnotationAndOverlays()
            mapView.showAnnotations(mapView.annotations, animated: true)
            
            UIView.animate(withDuration: 0.3) {
                self.inputActivationView.alpha = 1
                self.configureActionButton(config: .showMenu)
                self.animateRideActionView(shouldShow: false)
            }
        }
    }
    
    // MARK: - Helper Functions
    
    func configure() {
        configureUI()
        fetchUserData()
    }
    
    func configureUI() {
        configureMapView()
        configureRideActionView()
        
        view.addSubview(actionbutton)
        actionbutton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor,
                            paddingTop: 18, paddingLeft: 20, width: 40, height: 40)
        
        configureTableView()
    }
    
    func configureLocationInputActivationView() {
        
        view.addSubview(inputActivationView)
        inputActivationView.centerX(inView: view)
        inputActivationView.setDimensions(height: 50, width: view.frame.width - 64)
        inputActivationView.anchor(top: actionbutton.bottomAnchor, paddingTop: 32)
        inputActivationView.alpha = 0
        inputActivationView.delegate = self
        
        UIView.animate(withDuration: 2) {
            self.inputActivationView.alpha = 1
        }
    }
    
    func configureMapView() {
        view.addSubview(mapView)
        mapView.frame = view.frame
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.delegate = self
    }
    
    func configureLocationInputView() {
        locationInputView.delegate = self
        
        view.addSubview(locationInputView)
        locationInputView.anchor(top: view.topAnchor, left: view.leftAnchor,
                                 right: view.rightAnchor, height: locationInputViewHeight)
        locationInputView.alpha = 0
        
        UIView.animate(withDuration: 0.5) {
            self.locationInputView.alpha = 1
        } completion: { (_) in
            UIView.animate(withDuration: 0.4) {
                self.tableView.frame.origin.y = self.locationInputViewHeight
            } }
    }
    
    func configureRideActionView() {
        view.addSubview(rideActionView)
        rideActionView.delegate = self
        rideActionView.frame = CGRect(x: 0, y: view.frame.height,
                                      width: view.frame.width, height: rideActionViewHeight)
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(LocationCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 60
        tableView.tableFooterView = UIView()
        
        let height = view.frame.height - locationInputViewHeight
        tableView.frame = CGRect(x: 0, y: view.frame.height,
                                 width: view.frame.width, height: height)
        
        view.addSubview(tableView)
    }
    
    fileprivate func configureActionButton(config: actionButtonConfiguration) {
        switch config {
        case .showMenu:
            self.actionbutton.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
            self.actionBtnConfig = .showMenu
        case .dismissActionView:
            self.actionbutton.setImage(#imageLiteral(resourceName: "baseline_arrow_back_black_36dp-1").withRenderingMode(.alwaysOriginal), for: .normal)
            self.actionBtnConfig = .dismissActionView
        }
    }
    
    func dismissLocationView(completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: 0.3, animations: {
            self.locationInputView.alpha = 0
            self.tableView.frame.origin.y = self.view.frame.height
            self.locationInputView.removeFromSuperview()
        }, completion: completion)
    }
    
    func animateRideActionView(shouldShow: Bool, destenation: MKPlacemark? = nil,
                               config: RideActionViewConfiguration? = nil, user: User? = nil) {
        let yOrigin = shouldShow ? self.view.frame.height - self.rideActionViewHeight : self.view.frame.height
        
        UIView.animate(withDuration: 0.3) {
            self.rideActionView.frame.origin.y = yOrigin
        }
        
        if shouldShow {
            guard let config = config else { return }
            
            if let destenation = destenation {
                rideActionView.destenation = destenation
            }
            
            if let user = user {
                rideActionView.user = user
            }
            
            rideActionView.configureUI(withConfig: config)
        }
    }
    
    // MARK: - API
    
    func fetchUserData() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        DatabaseManager.shared.fetchUserData(uid: currentUid) { (user) in
            self.user = user
        }
    }
    
    func fetchDriverData() {
        guard let location = locationManager?.location else { return }
        DatabaseManager.shared.fetchDriver(location: location) { (driver) in
            guard let coordinate = driver.location?.coordinate else { return }
            let annotation = DriverAnnotation(uid: driver.uid, coordinate: coordinate)
            
            var driverIsVisible: Bool {
                return self.mapView.annotations.contains { (annotation) -> Bool in
                    guard let driverAnno = annotation as? DriverAnnotation else {
                        return false }
                    if driverAnno.uid == driver.uid {
                        // update position here
                        driverAnno.updateAnnotationPosition(with: coordinate)
                        return true
                    }
                    return false
                }
            }
            
            if !driverIsVisible {
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    
    func observeTrips() {
        Service.shared.observeTrips { (trip) in
            self.trip = trip
        }
    }
    
    func observeCurrentTrip() {
        Service.shared.observeCurrentTrip { (trip) in
            self.trip = trip
            
            if trip.state == .accepted {
                self.shouldPresentLoadingView(false)
                guard let driverUid = trip.driverUid else { return }
                
                DatabaseManager.shared.fetchUserData(uid: driverUid) { driver in
                    self.animateRideActionView(shouldShow: true, config: .tripAccepted,
                                               user: driver)
                }
            }
        }
    }
    
    func checkIfAuthenticated() {
        if Auth.auth().currentUser?.uid == nil {
            DispatchQueue.main.async {
                let vc = LoginVC()
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: false, completion: nil)
            }
        } else {
            configure()
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
                } else {
                    print("Failed to log out....")
                    return
                } } } }
}

// MARK: - MapView Delegate

extension HomeVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? DriverAnnotation {
            let view = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifire)
            view.image = #imageLiteral(resourceName: "chevron-sign-to-right")
            return view
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let route = self.route {
            let polyline = route.polyline
            let lineRenderer = MKPolylineRenderer(polyline: polyline)
            lineRenderer.strokeColor = .mainBlueTint
            lineRenderer.lineWidth = 6
            
            return lineRenderer
        }
        
        return MKOverlayRenderer()
    }
    
}

// MARK: - Location Services

extension HomeVC {
    func enableLocationServices() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            print("Not determind")
            locationManager?.requestWhenInUseAuthorization()
        case .restricted, .denied:
            break
        case .authorizedAlways:
            print("Auth always ")
            locationManager?.startUpdatingLocation()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
            print("Auth When in Use")
            locationManager?.requestAlwaysAuthorization()
        @unknown default:
            break
        }
    }
}

// MARK: - Location Activation Delegate

extension HomeVC: LocationInputActivationDelegate {
    func presentLocationInputView() {
        inputActivationView.alpha = 0
        configureLocationInputView()
    }
}

// MARK: - MapView Helper Functions

private extension HomeVC {
    func searchBy(naturalLanguageQuery: String, completion: @escaping ([MKPlacemark]) -> Void) {
        var results = [MKPlacemark]()
        
        let request = MKLocalSearch.Request()
        request.region = mapView.region
        request.naturalLanguageQuery = naturalLanguageQuery
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            guard let response = response else { return }
            
            response.mapItems.forEach { (item) in
                results.append(item.placemark)
            }
            completion(results)
        }
    }
    
    func generatePolyline(toDestenation destenation: MKMapItem) {
        
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = destenation
        request.transportType = .automobile
        
        let directionRequest = MKDirections(request: request)
        directionRequest.calculate { [weak self] (response, error) in
            guard let strongSelf = self else { return }
            guard let response = response else { return }
            strongSelf.route = response.routes[0]
            guard let polyline = strongSelf.route?.polyline else { return }
            strongSelf.mapView.addOverlay(polyline)
        }
    }
    
    func removeAnnotationAndOverlays() {
        mapView.annotations.forEach { (annotation) in
            if let anno = annotation as? MKPointAnnotation {
                mapView.removeAnnotation(anno)
            }
        }
        
        if mapView.overlays.count > 0 {
            mapView.removeOverlay(mapView.overlays[0])
        }
    }
    
    func centerMapOnUserLocation() {
        guard let coordinate = locationManager?.location?.coordinate else { return }
        let region = MKCoordinateRegion(center: coordinate,
                                        latitudinalMeters: 2000,
                                        longitudinalMeters: 2000)
        mapView.setRegion(region, animated: true)
    }
}

// MARK: - Location Input View Delegate

extension HomeVC: LocationInputViewDelegate {
    
    func executeSearch(query: String) {
        searchBy(naturalLanguageQuery: query) { (results) in
            self.searchResult = results
            self.tableView.reloadData()
        }
    }
    
    func dismissLocationInputView() {
        dismissLocationView { (_) in
            UIView.animate(withDuration: 0.3) {
                self.inputActivationView.alpha = 1
            }
        }
    }
}

// MARK: - TableView Delegate and Datasource

extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Test"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : searchResult.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LocationCell
        
        if indexPath.section == 1 {
            cell.placeMark = searchResult[indexPath.row]
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let destenationPlacemark = searchResult[indexPath.row]
        
        configureActionButton(config: .dismissActionView)
        
        let destenation = MKMapItem(placemark: destenationPlacemark)
        generatePolyline(toDestenation: destenation)
        
        dismissLocationView { (_) in
            let annotation = MKPointAnnotation()
            annotation.coordinate = destenationPlacemark.coordinate
            self.mapView.addAnnotation(annotation)
            self.mapView.selectAnnotation(annotation, animated: true)
            
            let annotations = self.mapView.annotations.filter({ !$0.isKind(of:DriverAnnotation.self) })
            
            self.mapView.zoomToFit(annotations: annotations)
            
            self.animateRideActionView(shouldShow: true, destenation: destenationPlacemark,
                                       config: .requsetRide)
        }
    }
}

// MARK: - RideActionViewDelegate

extension HomeVC: RideActionViewDelegate {
    
    func uploadTrip(_ view: RideActionView) {
        
        guard let pickupCoordinates = locationManager?.location?.coordinate else { return }
        guard let destinationCoordinates = view.destenation?.coordinate else { return }
        
        shouldPresentLoadingView(true, message: "Finding your a ride...")
        
        Service.shared.uploadTrip(pickupCoordinates, destinationCoordinates) { (error, ref) in
            if let error = error {
                print("DEBUG: Failed to upload trip with error: \(error.localizedDescription)")
                return
            }
            UIView.animate(withDuration: 0.3) {
                self.rideActionView.frame.origin.y = self.view.frame.height
            }
        }
    }
    
    func cancelTrip() {
        DatabaseManager.shared.cancelTrip { (error, ref) in
            if let error = error {
                print("DEBUG: Error deleting trip.. \(error.localizedDescription)")
                return
            }
            
            self.centerMapOnUserLocation()
            self.animateRideActionView(shouldShow: false)
            self.removeAnnotationAndOverlays()
            
            self.actionbutton.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
            self.actionBtnConfig = .showMenu
        }
    }
}

// MARK: - PickupVCDelegate

extension HomeVC: PickupVCDelegate {
    
    func didAcceptTrip(_ trip: Trip) {
        let anno = MKPointAnnotation()
        anno.coordinate = trip.pickupCoordinates
        mapView.addAnnotation(anno)
        mapView.selectAnnotation(anno, animated: true)
        
        let placemark = MKPlacemark(coordinate: trip.pickupCoordinates)
        let mapItem = MKMapItem(placemark: placemark)
        generatePolyline(toDestenation: mapItem)
        
        mapView.zoomToFit(annotations: mapView.annotations)
        
        Service.shared.observeTripCancelled(trip: trip) {
            self.removeAnnotationAndOverlays()
            self.animateRideActionView(shouldShow: false)
            self.centerMapOnUserLocation()
            self.presentAlertController(withtitle: "Oops!",
                                        message: "The passenger has decided to cancel the ride. press ok to continue.")
        }
        
        self.dismiss(animated: true) {
            DatabaseManager.shared.fetchUserData(uid: trip.passengerUid) { passenger in
                self.animateRideActionView(shouldShow: true, config: .tripAccepted,
                                           user: passenger)
            }
        }
    }
}
