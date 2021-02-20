//
//  MenuVC.swift
//  Uber-Clone
//
//  Created by Saad Sherif on 2/17/21.
//

import UIKit

private let reuseIdentifire = "MenuCell"

enum MenuOptions: Int, CaseIterable, CustomStringConvertible {
    case yourTrips
    case settings
    case logout
    
    var description: String {
        switch self {
        case .yourTrips: return "Your Trips"
        case .settings: return "Settings"
        case .logout: return "Log Out"
        }
    }
}

protocol MenuVCDelegate: class {
    func didSelect(option: MenuOptions)
}

class MenuVC: UIViewController {
    
    // MARK: - Properties
    
    private let user: User
    
    weak var delegate: MenuVCDelegate?
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.clipsToBounds = true
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifire)
        return tableView
    }()
    
    private lazy var menuHeader: MenuHeader = {
        let frame = CGRect(x: 0,
                           y: 0,
                           width: self.view.frame.width - 80,
                           height: 140)
        
        let view = MenuHeader(user: user, frame: frame)
        return view
    }()
    
    // MARK: - LifeCycel
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundColor
        configureTableView()
    }
    
    // MARK: - Selectors
    
    // MARK: - Helper Functions
    
    func configureTableView() {
        tableView.rowHeight = 60
        tableView.tableHeaderView = menuHeader
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         left: view.leftAnchor,
                         bottom: view.bottomAnchor,
                         right: view.rightAnchor)
    }
}

// MARK: - TableView Deleagte and Datasource

extension MenuVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MenuOptions.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifire, for: indexPath)
        cell.backgroundColor = .white
        cell.textLabel?.textColor = .black
        guard let option = MenuOptions(rawValue: indexPath.row) else { return UITableViewCell() }
        cell.textLabel?.text = option.description
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let option = MenuOptions(rawValue: indexPath.row) else { return }
        delegate?.didSelect(option: option)
    }
}
