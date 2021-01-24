//
//  RideActionView.swift
//  Uber-Clone
//
//  Created by Saad Sherif on 1/14/21.
//

import UIKit
import MapKit

protocol RideActionViewDelegate: class {
    func uploadTrip(_ view: RideActionView)
}

class RideActionView: UIView {
    
    // MARK: - Properties
    
    var destenation: MKPlacemark? {
        didSet {
            titleLabel.text = destenation?.name
            addressLabel.text = destenation?.address
        }
    }
    
    weak var delegate: RideActionViewDelegate?
    
    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        lbl.textColor = .black
        lbl.text = "Test Address Title"
        lbl.textAlignment = .center
        return lbl
    }()
    
    private let addressLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        lbl.textColor = .lightGray
        lbl.text = "123 m st, Cairo Egy"
        lbl.textAlignment = .center
        return lbl
    }()
    
    private let uberXLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        lbl.textColor = .black
        lbl.text = "UberX"
        lbl.textAlignment = .center
        return lbl
    }()
    
    private lazy var infoView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        
        let label = UILabel()
        label.text = "X"
        label.font = UIFont.systemFont(ofSize: 30, weight: .medium)
        label.textColor = .white
        
        view.addSubview(label)
        label.centerX(inView: view)
        label.centerY(inView: view)
        
        return view
    }()
    
    private let actionButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .black
        btn.setTitle("CONFIRM UBER X", for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        btn.setTitleColor(.white, for: .normal)
        btn.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        return btn
    }()
    
    // MARK: - LifeCycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor  = .white
        addShadow()
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, addressLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.distribution = .fillEqually
        
        addSubview(stack)
        stack.centerX(inView: self)
        stack.anchor(top: topAnchor, paddingTop: 12)
        
        addSubview(infoView)
        infoView.centerX(inView: self)
        infoView.anchor(top: stack.bottomAnchor, paddingTop: 18)
        infoView.setDimensions(height: 60, width: 60)
        infoView.layer.cornerRadius = 30
        
        addSubview(uberXLabel)
        uberXLabel.anchor(top: infoView.bottomAnchor, paddingTop: 8)
        uberXLabel.centerX(inView: self)
        
        let sepratorView = UIView()
        sepratorView.backgroundColor = .lightGray
        addSubview(sepratorView)
        sepratorView.anchor(top: uberXLabel.bottomAnchor, left: leftAnchor,
                            right: rightAnchor, paddingTop: 8, height: 1)
        
        addSubview(actionButton)
        actionButton.anchor(left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor,
                            right: rightAnchor, paddingLeft: 12, paddingBottom: 10,
                            paddingRight: 12, height: 50)
        actionButton.layer.cornerRadius = 14
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    
    @objc func actionButtonPressed() {
        delegate?.uploadTrip(self)
    }
    
}
