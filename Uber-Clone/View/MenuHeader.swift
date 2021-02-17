//
//  MenuHeader.swift
//  Uber-Clone
//
//  Created by Saad Sherif on 2/17/21.
//

import UIKit

class MenuHeader: UIView {
    
    
    // MARK: - Properties
    
//    var user: User? {
//        didSet {
//            fullNameLabel.text = user?.fullName
//            emailLabel.text = user?.email
//        }
//    }
    
    private let user: User
    
    private let profileImageView: UIImageView = {
        let image = UIImageView()
        image.backgroundColor = .lightGray
        return image
    }()
    
    private lazy var fullNameLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        lbl.textColor = .white
        lbl.text = user.fullName
        return lbl
    }()
    
    private lazy var emailLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        lbl.textColor = .lightGray
        lbl.text = user.email
        return lbl
    }()
    
    // MARK: - LifeCycle
    
    init(user: User, frame: CGRect) {
        self.user = user
        super.init(frame: frame)
        backgroundColor = .backgroundColor
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helper Functions
    
    func configureUI() {
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor,
                                paddingTop: 8, paddingLeft: 12,
                                width: 64, height: 64)
        profileImageView.layer.cornerRadius = 32
        
        let stack = UIStackView(arrangedSubviews: [fullNameLabel, emailLabel])
        stack.distribution = .fillEqually
        stack.spacing = 4
        stack.axis = .vertical
        
        addSubview(stack)
        stack.centerY(inView: profileImageView,
                      leftAnchor: profileImageView.rightAnchor,
                      paddingLeft: 12)
    }
    
    
}
