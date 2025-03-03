//
//  DailyEmotionsView.swift
//  Hard_MAD
//
//  Created by dark type on 03.03.2025.
//

import UIKit

class DailyEmotionsView: UIView {
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
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        
        for emotionContainer in emotionContainers {
            emotionContainer.isHidden = true
            emotionContainer.transform = CGAffineTransform.identity
            emotionContainer.layer.removeAllAnimations()
        }
        
        var typeGroups: [Emotion.EmotionType: [JournalRecord]] = [:]
        
        for record in records {
            let type = record.emotion.emotionType
            var recordsForType = typeGroups[type] ?? []
            recordsForType.append(record)
            typeGroups[type] = recordsForType
        }
        
        let totalCount = records.count
        totalLabel.text = "\(totalCount) " + L10n.Common.Statistics.Records.plural(totalCount)
        var typePercentages: [(type: Emotion.EmotionType, percentage: Double)] = []
        
        for (type, records) in typeGroups {
            let percentage = Double(records.count) / Double(totalCount)
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
        
        setNeedsLayout()
        layoutIfNeeded()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.applyProportionalScaling(for: topTypes)
        }
    }
    
    private func applyProportionalScaling(for typeData: [(type: Emotion.EmotionType, percentage: Double)]) {
        let baseSize: CGFloat = 1.0
        let minScale: CGFloat = 0.7
        let maxScale: CGFloat = 1.3
        
        guard let maxPercentage = typeData.map({ $0.percentage }).max(),
              let minPercentage = typeData.map({ $0.percentage }).min()
        else {
            return
        }
        
        let percentageRange = max(0.01, maxPercentage - minPercentage)
        
        for (index, data) in typeData.enumerated() {
            if index < emotionContainers.count {
                var normalizedPercentage = (data.percentage - minPercentage) / percentageRange
                
                normalizedPercentage = normalizedPercentage * 0.7 + 0.15
                
                let scaleValue = minScale + (maxScale - minScale) * CGFloat(normalizedPercentage)
                
                if typeData.count > 1 {
                    let percentageDifferences = typeData.map { abs($0.percentage - data.percentage) }
                    let closestDifference = percentageDifferences.filter { $0 > 0 }.min() ?? 1.0
                    
                    if closestDifference < 0.05 {
                        let exaggeratedScale = scaleValue * CGFloat(1.0 + (data.percentage - minPercentage) * 0.3)
                        emotionContainers[index].transform = CGAffineTransform(scaleX: exaggeratedScale, y: exaggeratedScale)
                    } else {
                        emotionContainers[index].transform = CGAffineTransform(scaleX: scaleValue, y: scaleValue)
                    }
                } else {
                    emotionContainers[index].transform = CGAffineTransform(scaleX: baseSize, y: baseSize)
                }
            }
        }
    }
    
    private func setupCirclesLayout(count: Int) {
        guard count > 0 else { return }
        
        UIView.performWithoutAnimation {
            for circleView in emotionContainers {
                for constraint in circleView.constraints.filter({ $0.firstItem === circleView }) {
                    constraint.isActive = false
                }
            }
            
            let contentTopConstant: CGFloat = 100
            
            let verticalCenter = bounds.height / 2 + contentTopConstant / 2
            
            switch count {
            case 1:
                let circle = emotionContainers[0]
                NSLayoutConstraint.activate([
                    circle.centerXAnchor.constraint(equalTo: centerXAnchor),
                    circle.topAnchor.constraint(equalTo: topAnchor, constant: verticalCenter - bounds.height * 0.3),
                    circle.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.7),
                    circle.heightAnchor.constraint(equalTo: circle.widthAnchor)
                ])
                
            case 2:
                let circle1 = emotionContainers[0]
                let circle2 = emotionContainers[1]
                
                NSLayoutConstraint.activate([
                    circle1.centerXAnchor.constraint(equalTo: centerXAnchor, constant: -bounds.width * 0.1),
                    circle1.topAnchor.constraint(equalTo: topAnchor, constant: verticalCenter - bounds.height * 0.3),
                    circle1.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.6),
                    circle1.heightAnchor.constraint(equalTo: circle1.widthAnchor),
        
                    circle2.centerXAnchor.constraint(equalTo: centerXAnchor, constant: bounds.width * 0.15),
                    circle2.topAnchor.constraint(equalTo: topAnchor, constant: verticalCenter - bounds.height * 0.15),
                    circle2.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.6),
                    circle2.heightAnchor.constraint(equalTo: circle2.widthAnchor)
                ])
                
            case 3:
                let circle1 = emotionContainers[0]
                let circle2 = emotionContainers[1]
                let circle3 = emotionContainers[2]
                
                let circleSize: CGFloat = 0.5
                
                NSLayoutConstraint.activate([
                    circle1.centerXAnchor.constraint(equalTo: centerXAnchor),
                    circle1.topAnchor.constraint(equalTo: topAnchor, constant: verticalCenter - bounds.height * 0.25),
                    circle1.widthAnchor.constraint(equalTo: widthAnchor, multiplier: circleSize),
                    circle1.heightAnchor.constraint(equalTo: circle1.widthAnchor),
                    
                    circle2.centerXAnchor.constraint(equalTo: centerXAnchor, constant: -bounds.width * 0.2),
                    circle2.topAnchor.constraint(equalTo: topAnchor, constant: verticalCenter - bounds.height * 0.15),
                    circle2.widthAnchor.constraint(equalTo: widthAnchor, multiplier: circleSize),
                    circle2.heightAnchor.constraint(equalTo: circle2.widthAnchor),
                    
                    circle3.centerXAnchor.constraint(equalTo: centerXAnchor, constant: bounds.width * 0.2),
                    circle3.topAnchor.constraint(equalTo: topAnchor, constant: verticalCenter - bounds.height * 0.15),
                    circle3.widthAnchor.constraint(equalTo: widthAnchor, multiplier: circleSize),
                    circle3.heightAnchor.constraint(equalTo: circle3.widthAnchor)
                ])
                
            case 4:
                let circle1 = emotionContainers[0]
                let circle2 = emotionContainers[1]
                let circle3 = emotionContainers[2]
                let circle4 = emotionContainers[3]
                
                let circleSize: CGFloat = 0.45
                
                NSLayoutConstraint.activate([
                    circle1.centerXAnchor.constraint(equalTo: centerXAnchor),
                    circle1.topAnchor.constraint(equalTo: topAnchor, constant: verticalCenter - bounds.height * 0.42),
                    circle1.widthAnchor.constraint(equalTo: widthAnchor, multiplier: circleSize),
                    circle1.heightAnchor.constraint(equalTo: circle1.widthAnchor),
                    
                    circle2.centerXAnchor.constraint(equalTo: centerXAnchor, constant: -bounds.width * 0.2),
                    circle2.topAnchor.constraint(equalTo: topAnchor, constant: verticalCenter - bounds.height * 0.25),
                    circle2.widthAnchor.constraint(equalTo: widthAnchor, multiplier: circleSize),
                    circle2.heightAnchor.constraint(equalTo: circle2.widthAnchor),
                    
                    circle3.centerXAnchor.constraint(equalTo: centerXAnchor, constant: bounds.width * 0.2),
                    circle3.topAnchor.constraint(equalTo: topAnchor, constant: verticalCenter - bounds.height * 0.25),
                    circle3.widthAnchor.constraint(equalTo: widthAnchor, multiplier: circleSize),
                    circle3.heightAnchor.constraint(equalTo: circle3.widthAnchor),
                    
                    circle4.centerXAnchor.constraint(equalTo: centerXAnchor),
                    circle4.topAnchor.constraint(equalTo: topAnchor, constant: verticalCenter - bounds.height * 0.08),
                    circle4.widthAnchor.constraint(equalTo: widthAnchor, multiplier: circleSize),
                    circle4.heightAnchor.constraint(equalTo: circle4.widthAnchor)
                ])
                
            default:
                if let circle = emotionContainers.first {
                    NSLayoutConstraint.activate([
                        circle.centerXAnchor.constraint(equalTo: centerXAnchor),
                        circle.topAnchor.constraint(equalTo: topAnchor, constant: verticalCenter - bounds.height * 0.3),
                        circle.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.65),
                        circle.heightAnchor.constraint(equalTo: circle.widthAnchor)
                    ])
                }
            }
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
        UIView.performWithoutAnimation {
            gradientLayer.frame = bounds
            layer.cornerRadius = bounds.width / 2
        }
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
        transform = CGAffineTransform(scaleX: CGFloat(relativeSize), y: CGFloat(relativeSize))
        
        percentageLabel.text = "\(Int(percentage * 100))%"
        
        let colors = type.gradientType
        gradientLayer.colors = [
            colors.0.cgColor,
            colors.1.cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
    
        setNeedsLayout()
    }
}
