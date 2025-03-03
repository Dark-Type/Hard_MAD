//
//  MoodTimeOfDayView.swift
//  Hard_MAD
//
//  Created by dark type on 03.03.2025.
//

import UIKit

final class MoodTimeOfDayView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.Analysis.Title.daily
        label.font = UIFont.appFont(AppFont.fancy, size: 32)
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()
    
    private let chartView = UIView()
    
    private var timeOfDayLabels: [UILabel] = []
    
    private let barVerticalSpacing: CGFloat = 2
    
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
        addSubview(chartView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        chartView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: -25),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),
                  
            chartView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            chartView.leadingAnchor.constraint(equalTo: leadingAnchor),
            chartView.trailingAnchor.constraint(equalTo: trailingAnchor),
            chartView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
        
        createTimeLabels()
    }
    
    private func createTimeLabels() {
        for label in timeOfDayLabels {
            label.removeFromSuperview()
        }
        timeOfDayLabels = []
        
        let times = TimeOfDay.allCases
        let labelWidth = chartView.bounds.width / CGFloat(times.count)
        
        for (index, time) in times.enumerated() {
            let label = UILabel()
            label.text = time.rawValue
            label.font = UIFont.appFont(AppFont.regular, size: 14)
            label.textAlignment = .center
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.7
            label.numberOfLines = 2
            label.textColor = .white
            chartView.addSubview(label)
            timeOfDayLabels.append(label)
            
            label.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                label.bottomAnchor.constraint(equalTo: chartView.bottomAnchor),
                label.leadingAnchor.constraint(equalTo: chartView.leadingAnchor, constant: CGFloat(index) * labelWidth),
                label.widthAnchor.constraint(equalToConstant: labelWidth),
                label.heightAnchor.constraint(equalToConstant: 40)
            ])
        }
    }
    
    func configure(with data: [TimeOfDay: [EmotionFrequency]]) {
        for subview in chartView.subviews {
            subview.removeFromSuperview()
        }
        timeOfDayLabels.removeAll()
        createTimeLabels()
        
        let times = TimeOfDay.allCases
        let columnWidth = chartView.bounds.width / CGFloat(times.count)
        let maxColumnHeight: CGFloat = 450
        let columnSpacing: CGFloat = 6
        
        for (index, time) in times.enumerated() {
            let frequencies = data[time] ?? []
            
            var emotionTypeData: [Emotion.EmotionType: (percentage: Double, count: Int)] = [:]
            
            for frequency in frequencies {
                let emotionType = frequency.emotion.emotionType
                let currentValue = emotionTypeData[emotionType] ?? (percentage: 0, count: 0)
                emotionTypeData[emotionType] = (
                    percentage: currentValue.percentage + frequency.percentage,
                    count: currentValue.count + 1
                )
            }
            
            let sortedEmotionTypes = emotionTypeData.sorted { $0.value.percentage > $1.value.percentage }
            
            let columnContainer = UIView()
            columnContainer.backgroundColor = .clear
            chartView.addSubview(columnContainer)
            
            let columnX = CGFloat(index) * columnWidth + columnSpacing / 2
            let columnWidthWithSpacing = columnWidth - columnSpacing
            
            columnContainer.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                columnContainer.leadingAnchor.constraint(equalTo: chartView.leadingAnchor, constant: columnX),
                columnContainer.widthAnchor.constraint(equalToConstant: columnWidthWithSpacing),
                columnContainer.bottomAnchor.constraint(equalTo: chartView.bottomAnchor, constant: -44),
                columnContainer.heightAnchor.constraint(equalToConstant: maxColumnHeight)
            ])
            
            if sortedEmotionTypes.isEmpty {
                let emptyBar = UIView()
                emptyBar.backgroundColor = UIColor(red: 51 / 255, green: 51 / 255, blue: 51 / 255, alpha: 1.0)
                emptyBar.layer.cornerRadius = 8
                columnContainer.addSubview(emptyBar)
                
                emptyBar.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    emptyBar.leadingAnchor.constraint(equalTo: columnContainer.leadingAnchor),
                    emptyBar.trailingAnchor.constraint(equalTo: columnContainer.trailingAnchor),
                    emptyBar.heightAnchor.constraint(equalToConstant: maxColumnHeight),
                    emptyBar.bottomAnchor.constraint(equalTo: columnContainer.bottomAnchor)
                ])
                
                let countLabel = UILabel()
                countLabel.text = "0"
                countLabel.font = UIFont.appFont(AppFont.regular, size: 12)
                countLabel.textColor = UIColor(red: 153 / 255, green: 153 / 255, blue: 153 / 255, alpha: 1)
                countLabel.textAlignment = .center
                chartView.addSubview(countLabel)

                countLabel.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    countLabel.centerXAnchor.constraint(equalTo: columnContainer.centerXAnchor),
                    countLabel.topAnchor.constraint(equalTo: timeOfDayLabels[index].bottomAnchor)
                ])
                
                continue
            }
            
            var currentY: CGFloat = maxColumnHeight
            var totalRecords = 0
            
            for (_, value) in sortedEmotionTypes {
                totalRecords += value.count
            }
            
            let totalPercentage = sortedEmotionTypes.reduce(0.0) { $0 + $1.value.percentage }
            
            let numberOfGaps = max(0, sortedEmotionTypes.count - 1)
            let totalSpacingHeight = CGFloat(numberOfGaps) * barVerticalSpacing
            let availableHeight = maxColumnHeight - totalSpacingHeight
            
            for (i, (emotionType, value)) in sortedEmotionTypes.enumerated() {
                let adjustedPercentage = totalPercentage > 0 ? value.percentage / totalPercentage : 0
                let barHeight = CGFloat(adjustedPercentage) * availableHeight
                
                if barHeight >= 5 {
                    let barView = UIView()
                    barView.layer.cornerRadius = 8
                    barView.clipsToBounds = true
                    columnContainer.addSubview(barView)
                    
                    barView.translatesAutoresizingMaskIntoConstraints = false
                    
                    NSLayoutConstraint.activate([
                        barView.leadingAnchor.constraint(equalTo: columnContainer.leadingAnchor),
                        barView.trailingAnchor.constraint(equalTo: columnContainer.trailingAnchor),
                        barView.heightAnchor.constraint(equalToConstant: barHeight),
                        barView.bottomAnchor.constraint(equalTo: columnContainer.topAnchor, constant: currentY)
                    ])
                    
                    let gradientLayer = CAGradientLayer()
                    let colors = emotionType.gradientType
                    gradientLayer.colors = [
                        colors.0.cgColor,
                        colors.1.cgColor
                    ]
                    gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
                    gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
                    gradientLayer.frame = CGRect(x: 0, y: 0, width: columnWidthWithSpacing, height: barHeight)
                    gradientLayer.cornerRadius = 8
                    barView.layer.insertSublayer(gradientLayer, at: 0)
                    
                    let percentLabel = UILabel()
                    percentLabel.text = "\(Int(value.percentage * 100))%"
                    percentLabel.textColor = .black
                    percentLabel.font = UIFont.appFont(AppFont.bold, size: 12)
                    percentLabel.textAlignment = .center
                    barView.addSubview(percentLabel)
                    
                    percentLabel.translatesAutoresizingMaskIntoConstraints = false
                    NSLayoutConstraint.activate([
                        percentLabel.centerXAnchor.constraint(equalTo: barView.centerXAnchor),
                        percentLabel.centerYAnchor.constraint(equalTo: barView.centerYAnchor)
                    ])
                    
                    percentLabel.isHidden = barHeight < 25
                    
                    currentY -= barHeight
                    
                    if i < sortedEmotionTypes.count - 1 {
                        currentY -= barVerticalSpacing
                    }
                }
            }
            
            let countLabel = UILabel()
            countLabel.text = "\(totalRecords)"
            countLabel.font = UIFont.appFont(AppFont.regular, size: 12)
            countLabel.textColor = UIColor(red: 153 / 255, green: 153 / 255, blue: 153 / 255, alpha: 1)
            countLabel.textAlignment = .center
            chartView.addSubview(countLabel)

            countLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                countLabel.centerXAnchor.constraint(equalTo: columnContainer.centerXAnchor),
                countLabel.topAnchor.constraint(equalTo: timeOfDayLabels[index].bottomAnchor)
            ])
        }
        
        for label in timeOfDayLabels {
            chartView.bringSubviewToFront(label)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    
        for subview in chartView.subviews {
            let columnContainer = subview
            if columnContainer != timeOfDayLabels.first {
                for barView in columnContainer.subviews {
                    for layer in barView.layer.sublayers ?? [] {
                        if let gradientLayer = layer as? CAGradientLayer {
                            gradientLayer.frame = barView.bounds
                        }
                    }
                }
            }
        }
    }
}
