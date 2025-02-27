//
//  JournalEntryCell.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//
import UIKit

final class JournalEntryCell: UITableViewCell {
    private let emotionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let noteLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(emotionLabel)
        contentView.addSubview(noteLabel)
        contentView.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            emotionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            emotionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            noteLabel.topAnchor.constraint(equalTo: emotionLabel.bottomAnchor, constant: 4),
            noteLabel.leadingAnchor.constraint(equalTo: emotionLabel.leadingAnchor),
            noteLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            dateLabel.topAnchor.constraint(equalTo: noteLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: noteLabel.leadingAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with record: JournalRecord) {
        emotionLabel.text = record.emotion.rawValue
        noteLabel.text = record.note
        dateLabel.text = record.createdAt.formatted(date: .abbreviated, time: .shortened)
    }
}
