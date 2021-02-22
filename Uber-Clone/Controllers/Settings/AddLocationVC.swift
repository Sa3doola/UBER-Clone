//
//  AddLocationVC.swift
//  Uber-Clone
//
//  Created by Saad Sherif on 2/20/21.
//

import UIKit
import MapKit

private let reuseID = "AddLocationCell"

protocol AddLocationVCDelegate: class {
    func updateLocation(locationString: String, type: LocationType)
}

class AddLocationVC: UITableViewController {
    
    // MARK: - Properties
    
    private let searchBar = UISearchBar()
    private let searchComplete = MKLocalSearchCompleter()
    private var searchResults = [MKLocalSearchCompletion]() {
        didSet{ tableView.reloadData() }
    }
    private let type: LocationType
    private let location: CLLocation
    
    weak var delegate: AddLocationVCDelegate?
    
    // MARK: - LifeCycle
    
    init(type: LocationType, location: CLLocation) {
        self.type = type
        self.location = location
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureSearchBar()
        configureSearchCompleter()
    }
    
    // MARK: - Helper Functions
    
    func configureTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseID)
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 60

        tableView.addShadow()
    }
    
    func configureSearchBar() {
        searchBar.sizeToFit()
        searchBar.delegate = self
        navigationItem.titleView = searchBar
    }
    
    func configureSearchCompleter() {
        let region = MKCoordinateRegion(center: location.coordinate,
                                        latitudinalMeters: 2000,
                                        longitudinalMeters: 2000)
        searchComplete.region = region
        searchComplete.delegate = self
    }
    
    // MARK: - Selectors
}

// MARK: - UITableView Delegate and DataSource

extension AddLocationVC {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: reuseID)
        cell.backgroundColor = .white
        cell.textLabel?.textColor = .black
        let results = searchResults[indexPath.row]
        cell.textLabel?.text = results.title
        cell.detailTextLabel?.text = results.subtitle
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let results = searchResults[indexPath.row]
        let title = results.title
        let subtitle = results.subtitle
        let locationString = title + " " + subtitle
        let trimmedLocation = locationString.replacingOccurrences(of: ", Egypt", with: "")
        delegate?.updateLocation(locationString: trimmedLocation, type: type)
    }
}

// MARK: - UISearchBar Delegate

extension AddLocationVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchComplete.queryFragment = searchText
    }
}

// MARK: - MKLocalSearchCompleter Delegate

extension AddLocationVC: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
    }
}
