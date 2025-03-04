//
//  MostFrequentEmotionsView.swift
//  Hard_MAD
//
//  Created by dark type on 03.03.2025.
//

import UIKit

final class MostFrequentEmotionsView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.Analysis.Title.frequent
        label.font = UIFont.appFont(AppFont.fancy, size: 32)
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.allowsSelection = false
        tableView.rowHeight = 50
        tableView.isScrollEnabled = false
        tableView.alwaysBounceVertical = false
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.verticalScrollIndicatorInsets = .zero
        
        tableView.register(EmotionFrequencyCell.self, forCellReuseIdentifier: EmotionFrequencyCell.reuseIdentifier)
        
        tableView.dataSource = self
        return tableView
    }()
    
    private var emotionsData: [(emotion: Emotion, count: Int)] = []
    private var maxCount: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        addSubview(titleLabel)
        addSubview(tableView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -40)
        ])
        layer.cornerRadius = 16
        clipsToBounds = true
    }
    
    func configure(with data: [(emotion: Emotion, count: Int)]) {
        emotionsData = data.sorted { $0.count > $1.count }
        maxCount = emotionsData.first?.count ?? 1
        
        for constraint in tableView.constraints {
            if constraint.firstAttribute == .height && constraint.firstItem === tableView {
                constraint.isActive = false
            }
        }
        
        let rowHeight: CGFloat = 50
        let totalHeight = CGFloat(min(emotionsData.count, 5)) * rowHeight
        
        let heightConstraint = tableView.heightAnchor.constraint(equalToConstant: totalHeight)
        heightConstraint.isActive = true
        
        tableView.tableHeaderView = nil
        tableView.tableFooterView = nil
        
        tableView.reloadData()
        
        tableView.contentOffset = CGPoint.zero
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    // MARK: - Emotion Frequency Cell
    
    private class EmotionFrequencyCell: UITableViewCell {
        static var reuseIdentifier: String { return String(describing: EmotionFrequencyCell.self) }
        
        private var gradientLayer: CAGradientLayer?
        private var fixedBarStartPosition: CGFloat = 180
        
        private let emotionImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            return imageView
        }()
        
        private let nameLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.appFont(AppFont.regular, size: 16)
            label.textColor = .white
            label.lineBreakMode = .byTruncatingTail
            label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
            return label
        }()
        
        private let barContainer: UIView = {
            let view = UIView()
            view.backgroundColor = .clear
            return view
        }()
        
        private let barView: UIView = {
            let view = UIView()
            view.layer.cornerRadius = 20
            return view
        }()
        
        private let countLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.appFont(AppFont.regular, size: 14)
            label.textColor = .black
            label.textAlignment = .left
            return label
        }()
        
        private var barWidthConstraint: NSLayoutConstraint?
        
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
                
            let maxNameLabelWidth = fixedBarStartPosition - 8 - 30 - 6 - 8
                
            if let existingConstraint = nameLabel.constraints.first(where: { $0.firstAttribute == .width }) {
                existingConstraint.constant = maxNameLabelWidth
            } else {
                nameLabel.widthAnchor.constraint(lessThanOrEqualToConstant: maxNameLabelWidth).isActive = true
            }
                
            gradientLayer?.frame = barView.bounds
        }

        private func setupUI() {
            backgroundColor = .clear
            selectionStyle = .none
               
            contentView.addSubview(emotionImageView)
            contentView.addSubview(nameLabel)
            contentView.addSubview(barContainer)
            barContainer.addSubview(barView)
            barView.addSubview(countLabel)
               
            emotionImageView.translatesAutoresizingMaskIntoConstraints = false
            nameLabel.translatesAutoresizingMaskIntoConstraints = false
            barContainer.translatesAutoresizingMaskIntoConstraints = false
            barView.translatesAutoresizingMaskIntoConstraints = false
            countLabel.translatesAutoresizingMaskIntoConstraints = false
               
            NSLayoutConstraint.activate([
                emotionImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
                emotionImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                emotionImageView.widthAnchor.constraint(equalToConstant: 30),
                emotionImageView.heightAnchor.constraint(equalToConstant: 30),
                   
                nameLabel.leadingAnchor.constraint(equalTo: emotionImageView.trailingAnchor, constant: 6),
                nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

                barContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: fixedBarStartPosition),
                barContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
                barContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                barContainer.heightAnchor.constraint(equalToConstant: 40),
                   
                barView.leadingAnchor.constraint(equalTo: barContainer.leadingAnchor),
                barView.topAnchor.constraint(equalTo: barContainer.topAnchor),
                barView.bottomAnchor.constraint(equalTo: barContainer.bottomAnchor),
                   
                countLabel.leadingAnchor.constraint(equalTo: barView.leadingAnchor, constant: 10),
                countLabel.centerYAnchor.constraint(equalTo: barView.centerYAnchor)
            ])
               
            nameLabel.numberOfLines = 1
            nameLabel.lineBreakMode = .byClipping
            nameLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
            nameLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
               
            barWidthConstraint = barView.widthAnchor.constraint(equalToConstant: 0)
            barWidthConstraint?.isActive = true
        }
        
        func configure(with emotion: Emotion, count: Int, maxCount: Int, totalWidth: CGFloat) {
            emotionImageView.image = emotion.image
            emotionImageView.clipsToBounds = true
            
            nameLabel.text = emotion.rawValue
            countLabel.text = "\(count)"
            
            layoutIfNeeded()
            
            let nameLabelWidth = nameLabel.intrinsicContentSize.width
            let availableWidth = barContainer.bounds.width > 0 ?
                barContainer.bounds.width :
                totalWidth - (16 + 30 + 12 + nameLabelWidth + 16 + 16)
                
            let minBarWidth: CGFloat = 60
            let maxBarWidth: CGFloat = min(200, max(minBarWidth, availableWidth - 10))
           
            if count == 1 && maxCount > 1 {
                barWidthConstraint?.constant = minBarWidth
            } else {
                let ratio = Double(count) / Double(maxCount)
                let calculatedWidth = minBarWidth + CGFloat(ratio) * (maxBarWidth - minBarWidth)
                barWidthConstraint?.constant = calculatedWidth
            }
            
            barView.layer.sublayers?.forEach { if $0 is CAGradientLayer { $0.removeFromSuperlayer() } }
            
            let newGradientLayer = CAGradientLayer()
            let colors = emotion.emotionType.gradientType
            newGradientLayer.colors = [
                colors.1.cgColor,
                colors.0.cgColor
            ]
            newGradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            newGradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
            newGradientLayer.cornerRadius = 20
            barView.layer.insertSublayer(newGradientLayer, at: 0)
            gradientLayer = newGradientLayer
            
            layoutIfNeeded()
        }
    }
}

extension MostFrequentEmotionsView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(emotionsData.count, 5)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EmotionFrequencyCell.reuseIdentifier) as? EmotionFrequencyCell
            ?? EmotionFrequencyCell(style: .default, reuseIdentifier: EmotionFrequencyCell.reuseIdentifier)
            
        if indexPath.row < emotionsData.count {
            let data = emotionsData[indexPath.row]
            let availableWidth = tableView.bounds.width
            cell.configure(with: data.emotion, count: data.count, maxCount: maxCount, totalWidth: availableWidth)
        }
            
        return cell
    }
}

extension UITableView {
    func register(cellType: UITableViewCell.Type) {
        register(cellType, forCellReuseIdentifier: String(describing: cellType))
    }
}
