//
//  EmotionCell.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//

import UIKit

final class EmotionCell: UICollectionViewCell {
    // MARK: - Properties

    private var isSelectedEmotion = false
    
    // MARK: - UI Components

    private let circleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.backgroundColor = .lightGray
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.appFont(AppFont.fancy, size: 12)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        
        contentView.clipsToBounds = false
        
        contentView.addSubview(circleView)
        
        NSLayoutConstraint.activate([
            circleView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            circleView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            circleView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            circleView.heightAnchor.constraint(equalTo: circleView.widthAnchor)
        ])
        
        circleView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: circleView.leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: circleView.trailingAnchor, constant: -4)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        circleView.layer.cornerRadius = circleView.bounds.width / 2
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        transform = .identity
        setSelected(false)
    }

    func setHighlighted(_ highlighted: Bool) {
        if highlighted {
            transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        } else {
            transform = .identity
        }
    }

    // MARK: - Configuration
    
    func configure(with emotion: Emotion) {
        titleLabel.text = emotion.rawValue
        accessibilityIdentifier = "emotionCell_\(emotion.rawValue)"
        circleView.backgroundColor = emotion.color
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    // MARK: - Selection
    
    func setSelected(_ selected: Bool) {
        isSelectedEmotion = selected
        
        if selected {
            titleLabel.font = UIFont.appFont(AppFont.fancy, size: 16)
        } else {
            titleLabel.font = UIFont.appFont(AppFont.fancy, size: 12)
        }
    }
}
