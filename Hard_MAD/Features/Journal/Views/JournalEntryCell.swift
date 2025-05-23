//
//  JournalEntryCell.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//
import SnapKit
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
        return label
    }()
    
    private let prefixLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(AppFont.regular, size: 20)
        label.text = L10n.Journal.Cell.title
        label.textColor = .white
        return label
    }()
    
    private let emotionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(AppFont.fancy, size: 28)
        return label
    }()
    
    private let emotionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        return imageView
    }()
    
    private let textStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
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
        
        setupAccessibilityIdentifiers()
        setupConstraints()
        
        cardView.backgroundColor = UIColor(red: 44/255, green: 44/255, blue: 46/255, alpha: 1)
    }
    
    private func setupAccessibilityIdentifiers() {
        textStack.accessibilityIdentifier = "journalRecordCell"
        emotionImageView.accessibilityIdentifier = "emotionImageView"
        dateLabel.accessibilityIdentifier = "dateLabel"
        cardView.accessibilityIdentifier = "journalCellContentView"
    }
    
    private func setupConstraints() {
        cardView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-8)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(cardView).offset(16)
            make.leading.equalTo(cardView).offset(16)
        }
        
        textStack.snp.makeConstraints { make in
            make.leading.equalTo(cardView).offset(16)
            make.bottom.equalTo(cardView).offset(-16)
            make.trailing.lessThanOrEqualTo(emotionImageView.snp.leading).offset(-16)
        }
        
        emotionImageView.snp.makeConstraints { make in
            make.centerY.equalTo(textStack)
            make.trailing.equalTo(cardView).offset(-24)
            make.width.height.equalTo(60)
        }
    }
    
    // MARK: - Configuration
    
    func configure(with record: JournalRecord) {
        let emotionColor = record.emotion.color
        
        lastEmotionColor = emotionColor
        
        emotionLabel.text = record.emotion.rawValue.lowercased()
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
        let now = Date()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            return "сегодня, \(timeFormatter.string(from: date))"
        }
        
        if calendar.isDateInYesterday(date) {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            return "вчера, \(timeFormatter.string(from: date))"
        }
        
        let currentWeekComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
        let dateWeekComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        
        if currentWeekComponents.yearForWeekOfYear == dateWeekComponents.yearForWeekOfYear &&
            currentWeekComponents.weekOfYear == dateWeekComponents.weekOfYear
        {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE, HH:mm"
            dateFormatter.locale = Locale(identifier: "ru_RU")
            return dateFormatter.string(from: date)
        }
        
        let nowComponents = calendar.dateComponents([.year], from: now)
        let dateComponents = calendar.dateComponents([.year], from: date)
        
        if nowComponents.year == dateComponents.year {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d MMMM, HH:mm"
            dateFormatter.locale = Locale(identifier: "ru_RU")
            return dateFormatter.string(from: date)
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy, HH:mm"
        dateFormatter.locale = Locale(identifier: "ru_RU")
        return dateFormatter.string(from: date)
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
