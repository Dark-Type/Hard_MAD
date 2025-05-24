//
//  NotificationTimeView.swift
//  Hard_MAD
//
//  Created by dark type on 03.03.2025.
//

import UIKit

final class NotificationTimeView: UIView {
    // MARK: - UI Components
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.appFont(AppFont.regular, size: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "trashButton"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    
    private let notification: NotificationTime
    private let onDelete: (UUID) -> Void
    
    // MARK: - Initialization
    
    init(notification: NotificationTime, onDelete: @escaping (UUID) -> Void) {
        self.notification = notification
        self.onDelete = onDelete
        super.init(frame: .zero)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI SetupAppColors.Emotion.Common.commonColor.cgColor
    
    private func setupUI() {
        layer.backgroundColor = AppColors.Emotion.Common.commonColor
        layer.cornerRadius = 32
        
        addSubview(timeLabel)
        addSubview(deleteButton)
        
        accessibilityIdentifier = "notificationView_\(notification.id.uuidString)"
        timeLabel.accessibilityIdentifier = "notificationTimeLabel_\(notification.id.uuidString)"
        deleteButton.accessibilityIdentifier = "notificationDeleteButton_\(notification.id.uuidString)"
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 64),
            
            timeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            timeLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            deleteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            deleteButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: 48),
            deleteButton.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        timeLabel.text = notification.time
    }
    
    // MARK: - Actions
    
    @objc private func deleteButtonTapped() {
        onDelete(notification.id)
    }
}
