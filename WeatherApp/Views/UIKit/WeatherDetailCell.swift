//
//  WeatherDetailCell.swift
//  WeatherApp
//
//  Created by Arturo Aguilar on 8/14/23.
//

import Foundation
import UIKit

// Custom cell for the tables. It lets use place the data in partitions easily manageable and predictable.
// The main reason was because of the iconImageview needing proper placement that default layout did not streamline
class WeatherDetailCell: UITableViewCell {
    var titleLabel: UILabel!
    var valueLabel: UILabel!
    var iconImageView: UIImageView!
    var containerView: UIView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .white
        contentView.addSubview(containerView)
        
        titleLabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)
        
        valueLabel = UILabel(frame: .zero)
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.textAlignment = .right
        containerView.addSubview(valueLabel)
        
        iconImageView = UIImageView(frame: .zero)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        containerView.addSubview(iconImageView)
        
        NSLayoutConstraint.activate([
            // Container view constraints
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            // Title label constraints
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            // Icon constraints
            iconImageView.trailingAnchor.constraint(equalTo: valueLabel.leadingAnchor, constant: -8),
            iconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            // Value label constraints
            valueLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            valueLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            valueLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 16)
        ])
    }
}
