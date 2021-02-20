//
//  ContainerVC.swift
//  Uber-Clone
//
//  Created by Saad Sherif on 2/17/21.
//

import UIKit
import Firebase

class ContainerVC: UIViewController {
    //MARK: - Properties
    
    private let homeVC = HomeVC()
    private var menuVC: MenuVC!
    private let blackView = UIView()
    private var isExpended = false
    private lazy var xOrigin = self.view.frame.width - 80
    
    private var user: User? {
        didSet {
            guard let user = user else { return }
            homeVC.user = user
            configureMenuVC(withUser: user)
        }
    }
    
    
    //MARK: - LifeCycel
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkIfAuthenticated()
    }
    
    override var prefersStatusBarHidden: Bool {
        return isExpended
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    //MARK: - API
    
    func fetchUserData() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        DatabaseManager.shared.fetchUserData(uid: currentUid) { (user) in
            self.user = user
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
    
    //MARK: - Helper Functions
    
    func configure() {
        configureHomeVC()
        fetchUserData()
    }
    
    func configureHomeVC() {
        addChild(homeVC)
        homeVC.didMove(toParent: self)
        view.addSubview(homeVC.view)
        homeVC.delegate = self
    }
    
    func configureMenuVC(withUser user: User) {
        menuVC = MenuVC(user: user)
        addChild(menuVC)
        menuVC.didMove(toParent: self)
        view.insertSubview(menuVC.view, at: 0)
        menuVC.delegate = self
        configureBlackView()
    }
    
    func configureBlackView() {
        blackView.frame = CGRect(x: xOrigin,
                                 y: 0,
                                 width: 80,
                                 height: view.frame.height)
        blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        blackView.alpha = 0
        view.addSubview(blackView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissMenu))
        blackView.addGestureRecognizer(tap)
    }
    
    func animateMenu(shouldExpend: Bool, completion: ((Bool) -> Void)? = nil) {
        if shouldExpend {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.homeVC.view.frame.origin.x = self.xOrigin
                self.blackView.alpha = 1
            }, completion: nil)

        } else {
            self.blackView.alpha = 0
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.homeVC.view.frame.origin.x = 0
            }, completion: completion)
        }
        
        animateStatusBar()
    }
    
    func animateStatusBar() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        }, completion: nil)
    }
    
    // MARK: - Selectors
    
    @objc func dismissMenu() {
        isExpended = false
        animateMenu(shouldExpend: isExpended)
    }
}

// MARK: - HomeVC Delegate

extension ContainerVC: HomeVCDelegate {
    func handleMenuToggle() {
        isExpended.toggle()
        animateMenu(shouldExpend: isExpended)
    }
}

// MARK: - MenuVC Delegate

extension ContainerVC: MenuVCDelegate {
    func didSelect(option: MenuOptions) {
        isExpended.toggle()
        animateMenu(shouldExpend: isExpended) { (_) in
            switch option {
            case .yourTrips:
                break
            case .settings:
                guard let user = self.user else { return }
                let vc = SettingsVC(user: user)
                let navVC = UINavigationController(rootViewController: vc)
                navVC.modalPresentationStyle = .fullScreen
                navVC.modalTransitionStyle = .crossDissolve
                self.present(navVC, animated: true, completion: nil)
            case .logout:
                let alert = UIAlertController(title: nil,
                                              message: "Are you sure you want to log out?",
                                              preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Log Out",
                                              style: .destructive, handler: { (_) in
                    self.logOut()
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
