//
//  EmptyStateView.swift
//  Hard_MAD
//
//  Created by dark type on 04.03.2025.
//

import UIKit

class EmptyStateView: UIView {
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Сначала добавьте эмоции"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.appFont(AppFont.fancy, size: 18)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        addSubview(containerView)
        containerView.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            containerView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -20),
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),
            
            messageLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            messageLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
        ])
        
        accessibilityIdentifier = "emptyStateView"
        messageLabel.accessibilityIdentifier = "emptyStateMessage"
    }
}
