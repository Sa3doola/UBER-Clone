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
    func cancelTrip()
}

enum RideActionViewConfiguration {
    case requsetRide
    case tripAccepted
    case driverArrived
    case pickupPassenger
    case tripInProgress
    case endtrip
    
    init() {
        self = .requsetRide
    }
}

enum ButtonAction: CustomStringConvertible {
    case requsetRide
    case cancel
    case getDirection
    case pickup
    case dropOff
    
    var description: String {
        switch self {
        case .requsetRide: return "CONFIRM UBERX"
        case .cancel: return "CANCEL RIDE"
        case .getDirection: return "GET DIRECTION"
        case .pickup: return "PICKUP PASSENGER"
        case .dropOff: return "DROP OFF PASSENGER"
        }
    }
    
    init() {
        self = .requsetRide
    }
}

class RideActionView: UIView {
    
    // MARK: - Properties
    
    var destenation: MKPlacemark? {
        didSet {
            titleLabel.text = destenation?.name
            addressLabel.text = destenation?.address
        }
    }

    var buttonAction = ButtonAction()
    weak var delegate: RideActionViewDelegate?
    var user: User?
    
    var config = RideActionViewConfiguration() {
        didSet { configureUI(withConfig: config) }
    }
    
    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        lbl.textColor = .black
        lbl.textAlignment = .center
        return lbl
    }()
    
    private let addressLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        lbl.textColor = .lightGray
        lbl.textAlignment = .center
        return lbl
    }()
    
    private let uberInfoLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        lbl.textColor = .black
        lbl.text = "UberX"
        lbl.textAlignment = .center
        return lbl
    }()
    
    private let infoViewlabel: UILabel = {
        let label = UILabel()
        label.text = "X"
        label.font = UIFont.systemFont(ofSize: 30, weight: .medium)
        label.textColor = .white
        
        return label
    }()
    
    private lazy var infoView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        
        view.addSubview(infoViewlabel)
        infoViewlabel.centerX(inView: view)
        infoViewlabel.centerY(inView: view)
        
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
        
        addSubview(uberInfoLabel)
        uberInfoLabel.anchor(top: infoView.bottomAnchor, paddingTop: 8)
        uberInfoLabel.centerX(inView: self)
        
        let sepratorView = UIView()
        sepratorView.backgroundColor = .lightGray
        addSubview(sepratorView)
        sepratorView.anchor(top: uberInfoLabel.bottomAnchor, left: leftAnchor,
                            right: rightAnchor, paddingTop: 8, height: 1)
        
        addSubview(actionButton)
        actionButton.anchor(left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor,
                            right: rightAnchor, paddingLeft: 12, paddingBottom: 30,
                            paddingRight: 12, height: 50)
        actionButton.layer.cornerRadius = 14
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    
    @objc func actionButtonPressed() {
        switch buttonAction {
        case .requsetRide:
            delegate?.uploadTrip(self)
        case .cancel:
            delegate?.cancelTrip()
        case .getDirection:
            print("DEBUG Handle get direction..")
        case .pickup:
            print("DEBUG Handle pickup..")
        case .dropOff:
            print("DEBUG Handle drop off..")
            
        }
    }
    
    // MARK: - Helper Functions
    
    private func configureUI(withConfig config: RideActionViewConfiguration) {
        switch config {
        case .requsetRide:
            buttonAction = .requsetRide
            actionButton.setTitle(buttonAction.description, for: .normal)
        case .tripAccepted:
            guard let user = user else { return }
            
            if user.accountType == .passenger {
                titleLabel.text = "En Route To Passenger"
                buttonAction = .getDirection
                actionButton.setTitle(buttonAction.description, for: .normal)
            } else {
                buttonAction = .cancel
                actionButton.setTitle(buttonAction.description, for: .normal)
                titleLabel.text = "Driver En Route"
            }
            
            infoViewlabel.text = String(user.fullName.first ?? "X")
            uberInfoLabel.text = user.fullName
            
        case .pickupPassenger:
            titleLabel.text = "Arrived At Passenger Location"
            buttonAction = .pickup
            actionButton.setTitle(buttonAction.description, for: .normal)
            
        case .driverArrived:
            guard let user = user else { return }
            
            if user.accountType == .driver {
                titleLabel.text = "Driver Has Arrived"
                addressLabel.text = "Please meet driver at pickup location"
            }
            
        case .tripInProgress:
            guard let user = user else { return }
            
            if user.accountType == .driver {
                actionButton.setTitle("TRIP IN PROGRESS", for: .normal)
                actionButton.isEnabled = false
            } else {
                buttonAction = .getDirection
                actionButton.setTitle(buttonAction.description, for: .normal)
            }
            
            infoViewlabel.text = "En Route To Destenation"
    
        case .endtrip:
            guard let user = user else { return }
            
            if user.accountType == .driver {
                actionButton.setTitle("ARRIVED AT DESTENATION", for: .normal)
                actionButton.isEnabled = false
            } else {
                buttonAction = .dropOff
                actionButton.setTitle(buttonAction.description, for: .normal)
            }
        }
    }
}
