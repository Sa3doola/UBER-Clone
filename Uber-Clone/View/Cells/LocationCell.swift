//
//  LocationCell.swift
//  Uber-Clone
//
//  Created by Saad Sherif on 1/8/21.
//

import UIKit
import MapKit

class LocationCell: UITableViewCell {

    // MARK: - Properties
    
    var placeMark: MKPlacemark? {
        didSet {
            titleLabel.text = placeMark?.name
            addressLabel.text = placeMark?.address
        }
    }
    
    var type: LocationType? {
        didSet {
            titleLabel.text = type?.description
            addressLabel.text = type?.subTitle
        }
    }
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    var addressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helper Functions
    
    func configureUI() {
        
        selectionStyle = .none
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, addressLabel])
        stack.distribution = .fillEqually
        stack.axis = .vertical
        stack.spacing = 4
        
        addSubview(stack)
        stack.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 8)
    }
    
}
