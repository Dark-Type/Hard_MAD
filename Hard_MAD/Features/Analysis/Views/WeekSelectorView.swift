//
//  WeekSelectorView.swift
//  Hard_MAD
//
//  Created by dark type on 03.03.2025.
//

import SnapKit
import UIKit

final class WeekSelectorView: UIView {
    // MARK: - Constants
    
    fileprivate enum Constants {
        static let separatorHeight: CGFloat = 1
        static let separatorColor = AppColors.Surface.secondary
        static let collectionViewInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        static let cellSpacing: CGFloat = 8
        static let cellExtraWidth: CGFloat = 12
        static let cellTextPadding: CGFloat = 10
        static let weekCellCornerRadius: CGFloat = 2
        static let weekCellLabelBottomOffset: CGFloat = 4
        static let weekCellIndicatorHeight: CGFloat = 4
        static let weekCellIndicatorInsets: CGFloat = 12
        static let weekCellFontSize: CGFloat = 16
    }
    
    // MARK: - Properties
    
    weak var delegate: WeekSelectorDelegate?
    
    private var weeks: [DateInterval] = []
    private var selectedIndex: Int = 0
    
    private var collectionView: UICollectionView!
    private var separatorLine: UIView!
    
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
        backgroundColor = .black
        setupCollectionView()
        setupSeparatorLine()
        addSubviews()
    }
    
    private func setupCollectionView() {
        let layout = createCollectionViewLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(WeekCell.self, forCellWithReuseIdentifier: WeekCell.reuseIdentifier)
    }
    
    private func createCollectionViewLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = Constants.cellSpacing
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = Constants.collectionViewInsets
        return layout
    }
    
    private func setupSeparatorLine() {
        separatorLine = UIView()
        separatorLine.backgroundColor = Constants.separatorColor
    }
    
    private func addSubviews() {
        addSubview(collectionView)
        addSubview(separatorLine)
    }
    
    // MARK: - Constraints
    
    private func setupConstraints() {
        setupCollectionViewConstraints()
        setupSeparatorConstraints()
    }
    
    private func setupCollectionViewConstraints() {
        collectionView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-Constants.separatorHeight)
        }
    }
    
    private func setupSeparatorConstraints() {
        separatorLine.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(Constants.separatorHeight)
        }
    }
    
    // MARK: - Accessibility
    
    private func setupAccessibilityIdentifiers() {
        accessibilityIdentifier = "weekSelectorView"
        collectionView.accessibilityIdentifier = "weekSelectorCollectionView"
    }
    
    // MARK: - Configuration
    
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
    
    // MARK: - Width Calculation
    
    private func calculateWidthForWeekRange(_ weekRange: DateInterval) -> CGFloat {
        let calendar = Calendar.current
        let startDate = weekRange.start
        
        guard let endDate = calendar.date(byAdding: .day, value: 6, to: startDate) else {
            return 100
        }
        
        let displayText = formatWeekRangeText(startDate: startDate, endDate: endDate, calendar: calendar)
        
        let font = UIFont.appFont(AppFont.regular, size: Constants.weekCellFontSize)
        let attributes = [NSAttributedString.Key.font: font]
        let textWidth = (displayText as NSString).size(withAttributes: attributes).width
        
        return ceil(textWidth) + Constants.cellTextPadding
    }
    
    private func formatWeekRangeText(startDate: Date, endDate: Date, calendar: Calendar) -> String {
        let startComponents = calendar.dateComponents([.day, .month], from: startDate)
        let endComponents = calendar.dateComponents([.day, .month], from: endDate)
        
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMMM"
        monthFormatter.locale = Locale(identifier: "ru_RU")
        
        let startMonthFull = monthFormatter.string(from: startDate)
        let endMonthFull = monthFormatter.string(from: endDate)
        let startMonthAbbr = String(startMonthFull.prefix(3)).lowercased()
        let endMonthAbbr = String(endMonthFull.prefix(3)).lowercased()
        
        guard let startDay = startComponents.day, let endDay = endComponents.day else {
            return "Invalid date"
        }
        
        if startComponents.month == endComponents.month {
            return "\(startDay)-\(endDay) \(startMonthAbbr)"
        } else {
            return "\(startDay) \(startMonthAbbr) - \(endDay) \(endMonthAbbr)"
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension WeekSelectorView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let weekRange = weeks[indexPath.item]
        let width = calculateWidthForWeekRange(weekRange) + Constants.cellExtraWidth
        return CGSize(width: width, height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.item
        collectionView.reloadItems(at: [indexPath])
        delegate?.weekSelector(self, didSelectWeekAt: indexPath.item)
    }
}

// MARK: - UICollectionViewDataSource

extension WeekSelectorView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weeks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeekCell.reuseIdentifier, for: indexPath) as? WeekCell else {
            fatalError("Failed to dequeue WeekCell")
        }
        
        let weekRange = weeks[indexPath.item]
        cell.configure(with: weekRange, atIndex: indexPath.item)
        cell.isSelected = indexPath.item == selectedIndex
        
        return cell
    }
}

// MARK: - WeekCell

private class WeekCell: UICollectionViewCell {
    static let reuseIdentifier = "WeekCell"
    
    // MARK: - Properties
    
    private var weekLabel: UILabel!
    private var selectedIndicator: UIView!
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    private func setupViews() {
        setupWeekLabel()
        setupSelectedIndicator()
        addSubviews()
    }
    
    private func setupWeekLabel() {
        weekLabel = UILabel()
        weekLabel.textAlignment = .center
        weekLabel.font = UIFont.appFont(AppFont.regular, size: WeekSelectorView.Constants.weekCellFontSize)
        weekLabel.textColor = .white
    }
    
    private func setupSelectedIndicator() {
        selectedIndicator = UIView()
        selectedIndicator.backgroundColor = .white
        selectedIndicator.layer.cornerRadius = WeekSelectorView.Constants.weekCellCornerRadius
    }
    
    private func addSubviews() {
        contentView.addSubview(weekLabel)
        contentView.addSubview(selectedIndicator)
    }
    
    // MARK: - Constraints
    
    private func setupConstraints() {
        setupWeekLabelConstraints()
        setupSelectedIndicatorConstraints()
    }
    
    private func setupWeekLabelConstraints() {
        weekLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(selectedIndicator.snp.top).offset(-WeekSelectorView.Constants.weekCellLabelBottomOffset)
        }
    }
    
    private func setupSelectedIndicatorConstraints() {
        selectedIndicator.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(WeekSelectorView.Constants.weekCellIndicatorInsets)
            make.height.equalTo(WeekSelectorView.Constants.weekCellIndicatorHeight)
            make.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Configuration
    
    func configure(with weekRange: DateInterval, atIndex index: Int) {
        configure(with: weekRange)
        accessibilityIdentifier = "weekCell_\(index)"
    }
    
    func configure(with weekRange: DateInterval) {
        let calendar = Calendar.current
        let startDate = weekRange.start
        
        guard let endDate = calendar.date(byAdding: .day, value: 6, to: startDate) else {
            weekLabel.text = "Invalid week"
            return
        }
        
        weekLabel.text = formatWeekRangeText(startDate: startDate, endDate: endDate, calendar: calendar)
    }
    
    private func formatWeekRangeText(startDate: Date, endDate: Date, calendar: Calendar) -> String {
        let startComponents = calendar.dateComponents([.day, .month], from: startDate)
        let endComponents = calendar.dateComponents([.day, .month], from: endDate)
        
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMMM"
        monthFormatter.locale = Locale(identifier: "ru_RU")
        
        let startMonthFull = monthFormatter.string(from: startDate)
        let endMonthFull = monthFormatter.string(from: endDate)
        let startMonthAbbr = String(startMonthFull.prefix(3)).lowercased()
        let endMonthAbbr = String(endMonthFull.prefix(3)).lowercased()
        
        guard let startDay = startComponents.day, let endDay = endComponents.day else {
            return "Invalid date"
        }
        
        if startComponents.month == endComponents.month {
            return "\(startDay)-\(endDay) \(startMonthAbbr)"
        } else {
            return "\(startDay) \(startMonthAbbr) - \(endDay) \(endMonthAbbr)"
        }
    }
    
    // MARK: - Selection State
    
    override var isSelected: Bool {
        didSet {
            updateAppearance()
        }
    }
    
    private func updateAppearance() {
        weekLabel.textColor = .white
        selectedIndicator.isHidden = !isSelected
    }
}
