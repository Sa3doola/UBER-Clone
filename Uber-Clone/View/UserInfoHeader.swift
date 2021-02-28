//
//  UserInfoHeader.swift
//  Uber-Clone
//
//  Created by Saad Sherif on 2/20/21.
//

import UIKit

class UserInfoHeader: UIView {
    
    // MARK: - Properties
    
    private let user: User
    
    private lazy var profileImageView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        
        view.addSubview(initialLabel)
        initialLabel.centerX(inView: view)
        initialLabel.centerY(inView: view)
        
        return view
    }()
    
    private lazy var  initialLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 36, weight: .semibold)
        lbl.textColor = .white
        lbl.text = user.firstInitial
        return lbl
    }()
    
    private lazy var fullNameLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        lbl.textColor = .black
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
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helper Functions
    
    func configureUI() {
        backgroundColor = .white
        addSubview(profileImageView)
        profileImageView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 16)
        profileImageView.setDimensions(height: 64, width: 64)
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
