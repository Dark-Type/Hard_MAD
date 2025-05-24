//
//  EmptyStateView.swift
//  Hard_MAD
//
//  Created by dark type on 04.03.2025.
//

import SnapKit
import UIKit

class EmptyStateView: UIView {
    // MARK: - Constants
    
    private enum Constants {
        static let containerInsets: CGFloat = 20
        static let containerCornerRadius: CGFloat = 16
        static let containerBackgroundColor = AppColors.Surface.primary
        static let messageInsets: CGFloat = 20
        static let minContainerHeight: CGFloat = 100
        static let messageFontSize: CGFloat = 18
    }
    
    // MARK: - Properties
    
    private var containerView: UIView!
    private var messageLabel: UILabel!
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        setupAccessibilityIdentifiers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupConstraints()
        setupAccessibilityIdentifiers()
    }
    
    // MARK: - Setup Methods
    
    private func setupViews() {
        setupContainerView()
        setupMessageLabel()
        addSubviews()
    }
    
    private func setupContainerView() {
        containerView = UIView()
        containerView.backgroundColor = Constants.containerBackgroundColor
        containerView.layer.cornerRadius = Constants.containerCornerRadius
    }
    
    private func setupMessageLabel() {
        messageLabel = UILabel()
        messageLabel.text = L10n.Analysis.Empty.message
        messageLabel.textColor = .white
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont.appFont(AppFont.fancy, size: Constants.messageFontSize)
        messageLabel.numberOfLines = 0
    }
    
    private func addSubviews() {
        addSubview(containerView)
        containerView.addSubview(messageLabel)
    }
    
    // MARK: - Constraints
    
    private func setupConstraints() {
        setupContainerConstraints()
        setupMessageConstraints()
    }
    
    private func setupContainerConstraints() {
        containerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Constants.containerInsets)
            make.leading.trailing.equalToSuperview().inset(Constants.containerInsets)
            make.bottom.lessThanOrEqualToSuperview().offset(-Constants.containerInsets)
            make.height.greaterThanOrEqualTo(Constants.minContainerHeight)
        }
    }
    
    private func setupMessageConstraints() {
        messageLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Constants.messageInsets)
        }
    }
    
    // MARK: - Accessibility
    
    private func setupAccessibilityIdentifiers() {
        accessibilityIdentifier = "emptyStateView"
        messageLabel.accessibilityIdentifier = "emptyStateMessage"
    }
}
