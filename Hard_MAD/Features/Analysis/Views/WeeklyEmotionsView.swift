//
//  WeeklyEmotionsView.swift
//  Hard_MAD
//
//  Created by dark type on 03.03.2025.
//

import UIKit

final class WeeklyEmotionsView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.Analysis.Title.week
        label.font = UIFont.appFont(AppFont.fancy, size: 36)
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor(red: 51 / 255, green: 51 / 255, blue: 51 / 255, alpha: 1)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.backgroundColor = .clear
        tableView.allowsSelection = false
        tableView.alwaysBounceVertical = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    private var dailyEmotions: [(date: Date, records: [JournalRecord])] = []
    
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
        
        tableView.register(cellType: DayEmotionsCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        
        addSubview(titleLabel)
        addSubview(tableView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    
    func configure(with data: [Date: [JournalRecord]]) {
        let calendar = Calendar.current
        
        let sortedDays = data.keys.sorted { date1, date2 in
            
            let weekday1 = calendar.component(.weekday, from: date1)
            let weekday2 = calendar.component(.weekday, from: date2)
            
            let mondayFirst1 = (weekday1 + 5) % 7
            let mondayFirst2 = (weekday2 + 5) % 7
            
            return mondayFirst1 < mondayFirst2
        }.map { date in
            (date: date, records: data[date] ?? [])
        }
        
        dailyEmotions = sortedDays
        tableView.reloadData()
        
        adjustHeightIfNeeded()
    }
    
    private func adjustHeightIfNeeded() {
        tableView.layoutIfNeeded()
        
        var totalHeight: CGFloat = 0
        for i in 0 ..< dailyEmotions.count {
            let uniqueEmotionsCount = getUniqueEmotionsCount(for: dailyEmotions[i].records)
            let rows = ceil(Double(uniqueEmotionsCount) / 3.0)
            
            let cellHeight: CGFloat = rows > 1 ? 80 * CGFloat(rows) : 80
            totalHeight += cellHeight
        }
        
        if let heightConstraint = tableView.constraints.first(where: { $0.firstAttribute == .height }) {
            heightConstraint.constant = totalHeight
        } else {
            tableView.heightAnchor.constraint(equalToConstant: totalHeight).isActive = true
        }
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    private func getUniqueEmotionsCount(for records: [JournalRecord]) -> Int {
        var uniqueEmotions: Set<Emotion> = []
        for record in records {
            uniqueEmotions.insert(record.emotion)
        }
        return uniqueEmotions.count
    }

    // MARK: - Day Emotions Cell
    
    private class DayEmotionsCell: UITableViewCell {
        static var reuseIdentifier: String { return String(describing: DayEmotionsCell.self) }
        
        private let dateContainer: UIStackView = {
            let stack = UIStackView()
            stack.axis = .vertical
            stack.alignment = .leading
            stack.spacing = 2
            return stack
        }()
        
        private let dayOfWeekLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.appFont(AppFont.regular, size: 12)
            label.textColor = .white
            label.textAlignment = .left
            return label
        }()
        
        private let dateLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.appFont(AppFont.regular, size: 12)
            label.textColor = .white
            label.textAlignment = .left
            return label
        }()
        
        private let emotionsStackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 4
            stackView.distribution = .fillEqually
            stackView.alignment = .center
            return stackView
        }()
        
        private let emotionImagesView: UIView = {
            let view = UIView()
            return view
        }()
        
        private var cellHeight: CGFloat = 80
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            setupUI()
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupUI() {
            backgroundColor = .clear
            selectionStyle = .none
            
            contentView.addSubview(dateContainer)
            contentView.addSubview(emotionsStackView)
            contentView.addSubview(emotionImagesView)
            
            dateContainer.addArrangedSubview(dayOfWeekLabel)
            dateContainer.addArrangedSubview(dateLabel)
            
            dateContainer.translatesAutoresizingMaskIntoConstraints = false
            emotionsStackView.translatesAutoresizingMaskIntoConstraints = false
            emotionImagesView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                dateContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                dateContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
                dateContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
                dateContainer.widthAnchor.constraint(equalToConstant: 70),
                
                emotionsStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                emotionsStackView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 8),
                emotionsStackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8),
                emotionsStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                emotionsStackView.widthAnchor.constraint(greaterThanOrEqualToConstant: 70),
                
                emotionImagesView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
                emotionImagesView.widthAnchor.constraint(equalToConstant: 108),
                emotionImagesView.heightAnchor.constraint(equalToConstant: 70),
                emotionImagesView.leadingAnchor.constraint(greaterThanOrEqualTo: emotionsStackView.trailingAnchor, constant: 4),
                emotionImagesView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            ])
            
            dayOfWeekLabel.adjustsFontSizeToFitWidth = true
            dayOfWeekLabel.minimumScaleFactor = 0.7
            dateLabel.adjustsFontSizeToFitWidth = true
            dateLabel.minimumScaleFactor = 0.7
        }
        
        func configure(with date: Date, records: [JournalRecord]) {
            let weekdayFormatter = DateFormatter()
            weekdayFormatter.dateFormat = "EEEE"
            weekdayFormatter.locale = Locale(identifier: "ru_RU")
            dayOfWeekLabel.text = weekdayFormatter.string(from: date).capitalized
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d MMM"
            dateFormatter.locale = Locale(identifier: "ru_RU")
            let dateString = dateFormatter.string(from: date)

            let components = dateString.split(separator: " ")
            if components.count == 2 {
                let day = components[0]
                let month = String(components[1].prefix(3))
                dateLabel.text = "\(day) \(month)"
            } else {
                dateLabel.text = dateString
            }
            
            emotionsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            emotionImagesView.subviews.forEach { $0.removeFromSuperview() }
            
            if records.isEmpty {
                let placeholderView = UIView()
                placeholderView.backgroundColor = UIColor(red: 51 / 255, green: 51 / 255, blue: 51 / 255, alpha: 1.0)
                placeholderView.layer.cornerRadius = 15
                emotionImagesView.addSubview(placeholderView)
                   
                placeholderView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    placeholderView.widthAnchor.constraint(equalToConstant: 30),
                    placeholderView.heightAnchor.constraint(equalToConstant: 30),
                    placeholderView.trailingAnchor.constraint(equalTo: emotionImagesView.trailingAnchor),
                    placeholderView.centerYAnchor.constraint(equalTo: emotionImagesView.centerYAnchor)
                ])
            } else {
                var uniqueEmotions: [Emotion] = []
                for record in records {
                    if !uniqueEmotions.contains(record.emotion) {
                        uniqueEmotions.append(record.emotion)
                    }
                }
                
                for emotion in uniqueEmotions {
                    let nameLabel = UILabel()
                    nameLabel.text = emotion.rawValue
                    nameLabel.font = UIFont.appFont(AppFont.regular, size: 12)
                    nameLabel.textColor = UIColor(red: 153 / 255, green: 153 / 255, blue: 153 / 255, alpha: 1)
                    nameLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
                    
                    emotionsStackView.addArrangedSubview(nameLabel)
                }
                
                layoutEmotionImages(uniqueEmotions)
            }
        }
        
        private func layoutEmotionImages(_ emotions: [Emotion]) {
            let columns = min(3, emotions.count)
            let rows = Int(ceil(Double(emotions.count) / Double(columns)))
            let imageSize: CGFloat = 30
            let spacing: CGFloat = 6
            
            let totalGridHeight = CGFloat(rows) * imageSize + CGFloat(max(0, rows - 1)) * spacing
            
            cellHeight = rows > 1 ? 80 * CGFloat(rows) : 80
            
            for i in 0 ..< emotions.count {
                let row = i / columns
                let col = i % columns
                
                let emotion = emotions[i]
                
                let imageView = UIImageView(image: emotion.image)
                imageView.contentMode = .scaleAspectFit
                imageView.layer.cornerRadius = imageSize / 2
                imageView.clipsToBounds = true
                emotionImagesView.addSubview(imageView)
                
                imageView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    imageView.widthAnchor.constraint(equalToConstant: imageSize),
                    imageView.heightAnchor.constraint(equalToConstant: imageSize),

                    imageView.trailingAnchor.constraint(equalTo: emotionImagesView.trailingAnchor,
                                                        constant: -CGFloat(col) * (imageSize + spacing)),
                    imageView.topAnchor.constraint(equalTo: emotionImagesView.centerYAnchor,
                                                   constant: -totalGridHeight / 2 + CGFloat(row) * (imageSize + spacing))
                ])
            }
        }
        
        func getCalculatedHeight() -> CGFloat {
            return cellHeight
        }
    }
}

extension WeeklyEmotionsView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dailyEmotions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DayEmotionsCell.reuseIdentifier, for: indexPath) as? DayEmotionsCell else {
            return UITableViewCell()
        }
        
        let dayData = dailyEmotions[indexPath.row]
        cell.configure(with: dayData.date, records: dayData.records)
        
        return cell
    }
}

extension WeeklyEmotionsView {
    func adjustHeightBasedOnContent() {
        tableView.layoutIfNeeded()
        
        let numberOfRows = tableView.numberOfRows(inSection: 0)
        var totalHeight: CGFloat = 0
        
        for i in 0 ..< numberOfRows {
            let indexPath = IndexPath(row: i, section: 0)
            totalHeight += tableView.rectForRow(at: indexPath).height
        }
        
        totalHeight += 30
        
        if let heightConstraint = tableView.constraints.first(where: { $0.firstAttribute == .height }) {
            heightConstraint.constant = totalHeight
        } else {
            tableView.heightAnchor.constraint(equalToConstant: totalHeight).isActive = true
        }
    }
}
