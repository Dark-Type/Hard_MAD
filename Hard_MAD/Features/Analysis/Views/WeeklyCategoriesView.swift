//
//  DailyEmotionsView.swift
//  Hard_MAD
//
//  Created by dark type on 03.03.2025.
//

import UIKit

class WeeklyCategoriesView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.Analysis.Title.categories
        label.font = UIFont.appFont(AppFont.fancy, size: 36)
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()
    
    private let totalLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(AppFont.regular, size: 20)
        label.textColor = .white
        return label
    }()
    
    private var emotionContainers: [EmotionAnalysisCircleView] = []
    private var currentDate: Date?
    
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
        addSubview(totalLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        totalLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            totalLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            totalLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16)
        ])
        
        for _ in 0 ..< 4 {
            let circleView = EmotionAnalysisCircleView()
            circleView.isHidden = true
            addSubview(circleView)
            circleView.translatesAutoresizingMaskIntoConstraints = false
            emotionContainers.append(circleView)
        }
    }
    
    func configure(with records: [JournalRecord], forDate date: Date) {
        let totalCount = records.count
        totalLabel.text = "\(totalCount) " + L10n.Common.Statistics.Records.plural(totalCount) + " " + L10n.Analysis.Title.week.lowercased()

        for emotionContainer in emotionContainers {
            emotionContainer.isHidden = true
            emotionContainer.transform = .identity
            emotionContainer.layer.removeAllAnimations()
        }
        
        var typeGroups: [Emotion.EmotionType: [JournalRecord]] = [:]
        for record in records {
            let type = record.emotion.emotionType
            var recordsForType = typeGroups[type] ?? []
            recordsForType.append(record)
            typeGroups[type] = recordsForType
        }
        
        var typePercentages: [(type: Emotion.EmotionType, percentage: Double)] = []
        for (type, typeRecords) in typeGroups {
            let percentage = Double(typeRecords.count) / Double(max(1, totalCount))
            typePercentages.append((type: type, percentage: percentage))
        }
        
        typePercentages.sort { $0.percentage > $1.percentage }
        let topTypes = Array(typePercentages.prefix(4))
        
        setupCirclesLayout(count: topTypes.count)
        layoutIfNeeded()
        
        for (index, typeData) in topTypes.enumerated() {
            if index < emotionContainers.count {
                let circleView = emotionContainers[index]
                circleView.configureWithType(
                    type: typeData.type,
                    percentage: typeData.percentage,
                    relativeSize: 1.0
                )
                circleView.isHidden = false
            }
        }
        
        applyProportionalScaling(for: topTypes)
    }

    private func applyProportionalScaling(for typeData: [(type: Emotion.EmotionType, percentage: Double)]) {
        let baseScale: CGFloat = 1.0
        let minScale: CGFloat = 0.7
        let maxScale: CGFloat = 1.3
        
        guard !typeData.isEmpty else { return }
        
        if typeData.count == 1 {
            emotionContainers[0].transform = CGAffineTransform(scaleX: baseScale, y: baseScale)
        }
        else if typeData.count == 2 {
            if abs(typeData[0].percentage - typeData[1].percentage) < 0.01 {
                let equalScale = baseScale
                emotionContainers[0].transform = CGAffineTransform(scaleX: equalScale, y: equalScale)
                emotionContainers[1].transform = CGAffineTransform(scaleX: equalScale, y: equalScale)
            }
            else {
                let ratio = typeData[0].percentage / max(0.01, typeData[1].percentage)
                let firstScale = min(maxScale, max(minScale, CGFloat(ratio) * 0.9))
                let secondScale = minScale + (1.0 - (firstScale - minScale))
                    
                emotionContainers[0].transform = CGAffineTransform(scaleX: firstScale, y: firstScale)
                emotionContainers[1].transform = CGAffineTransform(scaleX: secondScale, y: secondScale)
            }
        }
        else {
            let totalPercentage = typeData.reduce(0) { $0 + $1.percentage }
            
            for (index, data) in typeData.enumerated() {
                if index < emotionContainers.count {
                    let relativePercentage = data.percentage / totalPercentage
                    let scaleRange = maxScale - minScale
                    let scale = minScale + CGFloat(relativePercentage) * scaleRange
                    emotionContainers[index].transform = CGAffineTransform(scaleX: scale, y: scale)
                }
            }
        }
    }
    
    private func setupCirclesLayout(count: Int) {
        guard count > 0 else { return }
        
        for circleView in emotionContainers {
            circleView.removeFromSuperview()
            addSubview(circleView)
            circleView.translatesAutoresizingMaskIntoConstraints = false
        }

        let screenWidth = UIScreen.main.bounds.width
        let baseCircleSize = min(screenWidth * 0.38, 160)
        let contentTopConstant: CGFloat = 200
        
        switch count {
        case 1:
            NSLayoutConstraint.activate([
                emotionContainers[0].centerXAnchor.constraint(equalTo: centerXAnchor),
                emotionContainers[0].topAnchor.constraint(equalTo: topAnchor, constant: contentTopConstant),
                emotionContainers[0].widthAnchor.constraint(equalToConstant: baseCircleSize * 1.5),
                emotionContainers[0].heightAnchor.constraint(equalTo: emotionContainers[0].widthAnchor)
            ])
            
        case 2:
            
            NSLayoutConstraint.activate([
                emotionContainers[0].centerXAnchor.constraint(equalTo: leadingAnchor, constant: baseCircleSize * 0.8),
                emotionContainers[0].topAnchor.constraint(equalTo: topAnchor, constant: contentTopConstant - 40),
                emotionContainers[0].widthAnchor.constraint(equalToConstant: baseCircleSize),
                emotionContainers[0].heightAnchor.constraint(equalTo: emotionContainers[0].widthAnchor),
                
                emotionContainers[1].centerXAnchor.constraint(equalTo: trailingAnchor, constant: -baseCircleSize * 0.8),
                emotionContainers[1].topAnchor.constraint(equalTo: topAnchor, constant: contentTopConstant + 60),
                emotionContainers[1].widthAnchor.constraint(equalToConstant: baseCircleSize),
                emotionContainers[1].heightAnchor.constraint(equalTo: emotionContainers[1].widthAnchor)
            ])
            
        case 3:
           
            let smallerCircleSize = baseCircleSize * 0.9
            
            NSLayoutConstraint.activate([
                emotionContainers[0].centerXAnchor.constraint(equalTo: centerXAnchor),
                emotionContainers[0].topAnchor.constraint(equalTo: topAnchor, constant: contentTopConstant),
                emotionContainers[0].widthAnchor.constraint(equalToConstant: baseCircleSize),
                emotionContainers[0].heightAnchor.constraint(equalTo: emotionContainers[0].widthAnchor),
                
                emotionContainers[1].centerXAnchor.constraint(equalTo: leadingAnchor, constant: smallerCircleSize * 0.8),
                emotionContainers[1].topAnchor.constraint(equalTo: topAnchor, constant: contentTopConstant + baseCircleSize * 0.75),
                emotionContainers[1].widthAnchor.constraint(equalToConstant: smallerCircleSize),
                emotionContainers[1].heightAnchor.constraint(equalTo: emotionContainers[1].widthAnchor),
                
                emotionContainers[2].centerXAnchor.constraint(equalTo: trailingAnchor, constant: -smallerCircleSize * 0.8),
                emotionContainers[2].topAnchor.constraint(equalTo: topAnchor, constant: contentTopConstant + baseCircleSize * 0.75),
                emotionContainers[2].widthAnchor.constraint(equalToConstant: smallerCircleSize),
                emotionContainers[2].heightAnchor.constraint(equalTo: emotionContainers[2].widthAnchor)
            ])
            
        case 4:
            let smallerCircleSize = baseCircleSize * 0.85
            
            NSLayoutConstraint.activate([
                emotionContainers[0].centerXAnchor.constraint(equalTo: centerXAnchor),
                emotionContainers[0].topAnchor.constraint(equalTo: topAnchor, constant: contentTopConstant),
                emotionContainers[0].widthAnchor.constraint(equalToConstant: baseCircleSize),
                emotionContainers[0].heightAnchor.constraint(equalTo: emotionContainers[0].widthAnchor),
                
                emotionContainers[1].centerXAnchor.constraint(equalTo: leadingAnchor, constant: smallerCircleSize * 0.7),
                emotionContainers[1].topAnchor.constraint(equalTo: topAnchor, constant: contentTopConstant + baseCircleSize * 0.6),
                emotionContainers[1].widthAnchor.constraint(equalToConstant: smallerCircleSize),
                emotionContainers[1].heightAnchor.constraint(equalTo: emotionContainers[1].widthAnchor),
                
                emotionContainers[2].centerXAnchor.constraint(equalTo: trailingAnchor, constant: -smallerCircleSize * 0.7),
                emotionContainers[2].topAnchor.constraint(equalTo: topAnchor, constant: contentTopConstant + baseCircleSize * 0.6),
                emotionContainers[2].widthAnchor.constraint(equalToConstant: smallerCircleSize),
                emotionContainers[2].heightAnchor.constraint(equalTo: emotionContainers[2].widthAnchor),
                
                emotionContainers[3].centerXAnchor.constraint(equalTo: centerXAnchor),
                emotionContainers[3].topAnchor.constraint(equalTo: topAnchor, constant: contentTopConstant + baseCircleSize * 1.2),
                emotionContainers[3].widthAnchor.constraint(equalToConstant: smallerCircleSize),
                emotionContainers[3].heightAnchor.constraint(equalTo: emotionContainers[3].widthAnchor)
            ])
            
        default:
            break
        }
    }
}

class EmotionAnalysisCircleView: UIView {
    private var gradientLayer = CAGradientLayer()
    private let percentageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(AppFont.regular, size: 20)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(gradientLayer)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = bounds.width / 2
        layer.cornerRadius = bounds.width / 2
        CATransaction.commit()
    }
    
    private func setupUI() {
        layer.cornerRadius = bounds.width / 2
        clipsToBounds = true
        
        addSubview(percentageLabel)
        
        percentageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            percentageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            percentageLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
            
        ])
    }
    
    func configureWithType(type: Emotion.EmotionType, percentage: Double, relativeSize: Double) {
        transform = .identity
        
        percentageLabel.text = "\(Int(percentage * 100))%"
        percentageLabel.textColor = .black
        
        gradientLayer.removeFromSuperlayer()
        gradientLayer = CAGradientLayer()
        layer.insertSublayer(gradientLayer, at: 0)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        let colors = type.gradientType
        gradientLayer.colors = [
            colors.0.cgColor,
            colors.1.cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = bounds.width / 2
        
        CATransaction.commit()
    }
}
