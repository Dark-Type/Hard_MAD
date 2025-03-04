//
//  JournalEntryCell.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//
import UIKit

final class JournalEntryCell: UITableViewCell {
    // MARK: - UI Components
    
    private let cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.cornerRadius = 16
        layer.startPoint = CGPoint(x: 1.0, y: 0.0)
        layer.endPoint = CGPoint(x: 0.0, y: 1.0)
        layer.locations = [0.0, 0.3, 0.7, 1.0]

        layer.frame = CGRect(x: 0, y: 0, width: 1000, height: 1000)
        return layer
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(AppFont.regular, size: 14)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let prefixLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(AppFont.regular, size: 20)
        label.text = L10n.Journal.Cell.title
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emotionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(AppFont.fancy, size: 28)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emotionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let textStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private var lastEmotionColor: UIColor?
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if cardView.bounds.width > 0 && cardView.bounds.height > 0 {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            gradientLayer.frame = cardView.bounds
            CATransaction.commit()
            
            if let color = lastEmotionColor {
                updateGradient(with: color)
            }
        }
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(cardView)
        
        cardView.layer.insertSublayer(gradientLayer, at: 0)
        
        textStack.addArrangedSubview(prefixLabel)
        textStack.addArrangedSubview(emotionLabel)
        
        cardView.addSubview(dateLabel)
        cardView.addSubview(textStack)
        cardView.addSubview(emotionImageView)
        
        textStack.accessibilityIdentifier = "journalRecordCell"
        emotionImageView.accessibilityIdentifier = "emotionImageView"
        dateLabel.accessibilityIdentifier = "dateLabel"
        cardView.accessibilityIdentifier = "journalCellContentView"
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            cardView.heightAnchor.constraint(equalToConstant: 158),
            
            dateLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            dateLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            
            textStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            textStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),
            textStack.trailingAnchor.constraint(lessThanOrEqualTo: emotionImageView.leadingAnchor, constant: -16),
            
            emotionImageView.centerYAnchor.constraint(equalTo: textStack.centerYAnchor),
            emotionImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),
            emotionImageView.widthAnchor.constraint(equalToConstant: 60),
            emotionImageView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        cardView.backgroundColor = UIColor(red: 44/255, green: 44/255, blue: 46/255, alpha: 1)
    }
    
    // MARK: - Configuration
    
    func configure(with record: JournalRecord) {
        let emotionColor = record.emotion.color
        
        lastEmotionColor = emotionColor
        
        emotionLabel.text = record.emotion.rawValue
        emotionLabel.textColor = emotionColor
        dateLabel.text = formatDate(record.createdAt)
        
        emotionImageView.image = record.emotion.image
        
        updateGradient(with: emotionColor)
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    private func updateGradient(with color: UIColor) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        let colorWithHighAlpha = color.withAlphaComponent(0.4)
        let colorWithMediumAlpha = color.withAlphaComponent(0.2)
        let colorWithLowAlpha = color.withAlphaComponent(0.1)
        let colorWithNoAlpha = color.withAlphaComponent(0.0)
        
        gradientLayer.colors = [
            colorWithHighAlpha.cgColor,
            colorWithMediumAlpha.cgColor,
            colorWithLowAlpha.cgColor,
            colorWithNoAlpha.cgColor
        ]
        
        gradientLayer.frame = cardView.bounds
        
        CATransaction.commit()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        emotionLabel.text = nil
        dateLabel.text = nil
        emotionImageView.image = nil
        lastEmotionColor = nil
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.clear.cgColor, UIColor.clear.cgColor, UIColor.clear.cgColor]
        CATransaction.commit()
    }

    // MARK: - Gradient Refresh
       
    func refreshGradient(with record: JournalRecord) {
        let emotionColor = record.emotion.color
        lastEmotionColor = emotionColor
           
        layoutIfNeeded()
           
        CATransaction.begin()
        CATransaction.setDisableActions(true)
           
        gradientLayer.frame = cardView.bounds
           
        let colorWithHighAlpha = emotionColor.withAlphaComponent(0.4)
        let colorWithMediumAlpha = emotionColor.withAlphaComponent(0.2)
        let colorWithLowAlpha = emotionColor.withAlphaComponent(0.1)
        let colorWithNoAlpha = emotionColor.withAlphaComponent(0.0)
           
        gradientLayer.colors = [
            colorWithHighAlpha.cgColor,
            colorWithMediumAlpha.cgColor,
            colorWithLowAlpha.cgColor,
            colorWithNoAlpha.cgColor
        ]
           
        CATransaction.commit()
           
        cardView.setNeedsDisplay()
    }
    
    // MARK: - Highlight and Selection
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        UIView.animate(withDuration: animated ? 0.1 : 0) {
            self.cardView.alpha = highlighted ? 0.9 : 1.0
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        UIView.animate(withDuration: animated ? 0.1 : 0) {
            self.cardView.alpha = selected ? 0.9 : 1.0
        }
    }
}
