//
//  StatisticView.swift
//  Hard_MAD
//
//  Created by dark type on 01.03.2025.
//

import UIKit

final class StatisticView: UIView {
    // MARK: - Properties

    private let statType: StatType
    
    private let titleFontSize: CGFloat = 12
    private let valueFontSize: CGFloat = 12
    
    // MARK: - UI Components

    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
        label.lineBreakMode = .byClipping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initialization

    init(type: StatType) {
        self.statType = type
        super.init(frame: .zero)
        setupUI()
    }
    
    convenience init(title: String) {
        let type: StatType
        switch title {
        case "Total Records":
            type = .records
        case "Today":
            type = .today
        case "Streak":
            type = .streak
        default:
            type = .records
        }
        self.init(type: type)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup

    private func setupUI() {
        layer.cornerRadius = 16
        backgroundColor = UIColor(red: 44/255, green: 44/255, blue: 46/255, alpha: 1)
        
        addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6)
        ])
        
        translatesAutoresizingMaskIntoConstraints = false
        
        setValue(0)
    }
    
    // MARK: - Configuration

    func setValue(_ value: Int) {
        let title: String
        let plural: String
        
        switch statType {
        case .records:
            title = ""
            plural = L10n.Common.Statistics.Records.plural(value)
        case .today:
            title = L10n.Common.Statistics.Today.title + ": "
            plural = L10n.Common.Statistics.Today.plural(value)
        case .streak:
            title = L10n.Common.Statistics.Streak.title + ": "
            plural = L10n.Common.Statistics.Streak.plural(value)
        }
        
        let attributedText = NSMutableAttributedString()
        
        let titlePart = NSAttributedString(
            string: title,
            attributes: [
                .font: UIFont.appFont(AppFont.regular, size: titleFontSize),
                .foregroundColor: UIColor.white.withAlphaComponent(0.85)
            ]
        )
        attributedText.append(titlePart)
        
        let valueAndPluralPart = NSAttributedString(
            string: "\(value) \(plural)",
            attributes: [
                .font: UIFont.appFont(AppFont.bold, size: valueFontSize),
                .foregroundColor: UIColor.white
            ]
        )
        attributedText.append(valueAndPluralPart)
        
        label.attributedText = attributedText
        
        setNeedsLayout()
        invalidateIntrinsicContentSize()
    }
    
    // MARK: - Layout & Sizing
    
    override var intrinsicContentSize: CGSize {
        guard let attributedText = label.attributedText else {
            return CGSize(width: 100, height: 40)
        }
        
        let textSize = attributedText.size()
        
        let width = textSize.width + 40
        let height = textSize.height + 12
        
        return CGSize(width: max(width, 100), height: max(height, 40))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = bounds.height/2
        
        if let attributedText = label.attributedText {
            let textWidth = attributedText.size().width
            let availableWidth = label.bounds.width
            
            if textWidth > availableWidth * 1.05 {
                superview?.setNeedsLayout()
            }
        }
    }
}
