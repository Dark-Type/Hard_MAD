//
//  WeekSelectorView.swift
//  Hard_MAD
//
//  Created by dark type on 03.03.2025.
//

import UIKit

final class WeekSelectorView: UIView {
    weak var delegate: WeekSelectorDelegate?
    
    private var weeks: [DateInterval] = []
    private var selectedIndex: Int = 0
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(WeekCell.self, forCellWithReuseIdentifier: WeekCell.reuseIdentifier)
        
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .black
        
        let separatorLine = UIView()
        separatorLine.backgroundColor = UIColor(red: 44/255, green: 44/255, blue: 46/255, alpha: 1)
        
        addSubview(collectionView)
        addSubview(separatorLine)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1),
            
            separatorLine.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorLine.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    func configure(with weeks: [DateInterval], selectedIndex: Int) {
        self.weeks = weeks
        self.selectedIndex = selectedIndex
        collectionView.reloadData()
        
        DispatchQueue.main.async {
            if !weeks.isEmpty {
                let indexPath = IndexPath(item: selectedIndex, section: 0)
                self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
                
                self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            }
        }
    }
    
    // MARK: - Cell
    
    private class WeekCell: UICollectionViewCell {
        static let reuseIdentifier = "WeekCell"
        
        private let weekLabel: UILabel = {
            let label = UILabel()
            label.textAlignment = .center
            label.font = UIFont.appFont(AppFont.regular, size: 16)
            return label
        }()
        
        private let selectedIndicator: UIView = {
            let view = UIView()
            view.backgroundColor = .white
            view.layer.cornerRadius = 2
            return view
        }()
        
        override var isSelected: Bool {
            didSet {
                updateAppearance()
            }
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupUI()
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupUI() {
            contentView.addSubview(weekLabel)
            contentView.addSubview(selectedIndicator)
            
            weekLabel.translatesAutoresizingMaskIntoConstraints = false
            selectedIndicator.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                weekLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
                weekLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                weekLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                weekLabel.bottomAnchor.constraint(equalTo: selectedIndicator.topAnchor, constant: -4),
                
                selectedIndicator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
                selectedIndicator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
                selectedIndicator.heightAnchor.constraint(equalToConstant: 4),
                selectedIndicator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
            
            updateAppearance()
        }
        
        func configure(with weekRange: DateInterval) {
            let calendar = Calendar.current
            let startDate = weekRange.start
            
            guard let endDate = calendar.date(byAdding: .day, value: 6, to: startDate) else {
                weekLabel.text = "Invalid week"
                return
            }
            
            let startComponents = calendar.dateComponents([.day, .month], from: startDate)
            let endComponents = calendar.dateComponents([.day, .month], from: endDate)
            
            let monthFormatter = DateFormatter()
            monthFormatter.dateFormat = "MMMM"
            monthFormatter.locale = Locale(identifier: "ru_RU")
            
            let startMonthFull = monthFormatter.string(from: startDate)
            let endMonthFull = monthFormatter.string(from: endDate)
            let startMonthAbbr = String(startMonthFull.prefix(3)).lowercased()
            let endMonthAbbr = String(endMonthFull.prefix(3)).lowercased()
            
            if startComponents.month == endComponents.month {
                guard let startDay = startComponents.day, let endDay = endComponents.day else {
                    weekLabel.text = "Invalid date"
                    return
                }
                
                weekLabel.text = "\(startDay)-\(endDay) \(startMonthAbbr)"
            } else {
                guard let startDay = startComponents.day, let endDay = endComponents.day else {
                    weekLabel.text = "Invalid date"
                    return
                }
                
                weekLabel.text = "\(startDay) \(startMonthAbbr) - \(endDay) \(endMonthAbbr)"
            }
        }
        
        private func updateAppearance() {
            weekLabel.textColor = .white
            selectedIndicator.isHidden = !isSelected
        }
    }
}

extension WeekSelectorView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let weekRange = weeks[indexPath.item]
        
        let width = calculateWidthForWeekRange(weekRange) + 12
        
        return CGSize(width: width, height: collectionView.bounds.height)
    }

    private func calculateWidthForWeekRange(_ weekRange: DateInterval) -> CGFloat {
        let calendar = Calendar.current
        let startDate = weekRange.start
        
        guard let endDate = calendar.date(byAdding: .day, value: 6, to: startDate) else {
            return 100
        }
        
        let startComponents = calendar.dateComponents([.day, .month], from: startDate)
        let endComponents = calendar.dateComponents([.day, .month], from: endDate)
        
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMMM"
        monthFormatter.locale = Locale(identifier: "ru_RU")
        
        let startMonthFull = monthFormatter.string(from: startDate)
        let endMonthFull = monthFormatter.string(from: endDate)
        let startMonthAbbr = String(startMonthFull.prefix(3)).lowercased()
        let endMonthAbbr = String(endMonthFull.prefix(3)).lowercased()
        
        var displayText = ""
        if startComponents.month == endComponents.month {
            guard let startDay = startComponents.day, let endDay = endComponents.day else {
                return 100
            }
            displayText = "\(startDay)-\(endDay) \(startMonthAbbr)"
        } else {
            guard let startDay = startComponents.day, let endDay = endComponents.day else {
                return 100
            }
            displayText = "\(startDay) \(startMonthAbbr) - \(endDay) \(endMonthAbbr)"
        }
        
        let font = UIFont.appFont(AppFont.regular, size: 16)
        let attributes = [NSAttributedString.Key.font: font]
        let textWidth = (displayText as NSString).size(withAttributes: attributes).width
        
        return ceil(textWidth) + 10
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.item
        
        collectionView.reloadItems(at: [indexPath])
        
        delegate?.weekSelector(self, didSelectWeekAt: indexPath.item)
    }
}

extension WeekSelectorView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weeks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeekCell.reuseIdentifier, for: indexPath) as? WeekCell else {
            fatalError("Failed to dequeue WeekCell")
        }
        
        let weekRange = weeks[indexPath.item]
        cell.configure(with: weekRange)
        cell.isSelected = indexPath.item == selectedIndex
        
        return cell
    }
}
