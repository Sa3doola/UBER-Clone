//
//  LocationInputActivationView.swift
//  Uber-Clone
//
//  Created by Saad Sherif on 1/8/21.
//

import UIKit

protocol LocationInputActivationDelegate {
    func presentLocationInputView()
}

class LocationInputActivationView: UIView {
    
    // MARK: - Properties
    
    var delegate: LocationInputActivationDelegate?
    
    let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .label
        return view
    }()
    
    let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Where To? "
        label.textColor = .secondaryLabel
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        configureGestureRecognizer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    
    @objc func handleViewTapped() {
        delegate?.presentLocationInputView()
    }
    
    // MARK: - Helper Functions
    
    func configureUI() {
        backgroundColor = .label
        DispatchQueue.main.async {
            self.addShadow()
        }
        
        addSubview(indicatorView)
        indicatorView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 16)
        indicatorView.setDimensions(height: 6, width: 6)
        
        addSubview(placeholderLabel)
        placeholderLabel.centerY(inView: self, leftAnchor: indicatorView.rightAnchor, paddingLeft: 20)
    }
    
    func configureGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleViewTapped))
        addGestureRecognizer(tap)
    }
}
