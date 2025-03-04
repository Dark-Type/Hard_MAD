//
//  QuestionView.swift
//  Hard_MAD
//
//  Created by dark type on 03.03.2025.
//

import UIKit

final class QuestionView: UIView {
    private enum Constants {
        static let itemHeight: CGFloat = 36
        static let spacing: CGFloat = 8
        static let unselectedColor = UIColor(red: 44/255, green: 44/255, blue: 46/255, alpha: 1)
        static let selectedColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1)
        static let horizontalPadding: CGFloat = 16
        static let plusButtonSize: CGFloat = 36
        static let minWidth: CGFloat = 80
    }
    
    private class AnswersFlowLayout: UICollectionViewFlowLayout {
        private var cachedAttributes: [UICollectionViewLayoutAttributes]?
        
        override func prepare() {
            super.prepare()
            
            guard let collectionView = collectionView else { return }
            
            minimumInteritemSpacing = Constants.spacing
            minimumLineSpacing = Constants.spacing
            sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            
            var layoutAttributes = [UICollectionViewLayoutAttributes]()
            let maxWidth = collectionView.bounds.width
            var x: CGFloat = sectionInset.left
            var y: CGFloat = sectionInset.top
            var rowMaxY: CGFloat = 0
            
            for section in 0..<collectionView.numberOfSections {
                for item in 0..<collectionView.numberOfItems(inSection: section) {
                    let indexPath = IndexPath(item: item, section: section)
                    let size = self.collectionView(collectionView, sizeForItemAt: indexPath)
                    
                    if x + size.width > maxWidth - sectionInset.right && x > sectionInset.left {
                        x = sectionInset.left
                        y = rowMaxY + minimumLineSpacing
                    }
                    
                    let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                    attributes.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
                    layoutAttributes.append(attributes)
                    
                    x += size.width + minimumInteritemSpacing
                    rowMaxY = max(rowMaxY, y + size.height)
                }
            }
            
            cachedAttributes = layoutAttributes
        }
        
        override var collectionViewContentSize: CGSize {
            guard let attributes = cachedAttributes, !attributes.isEmpty else {
                return CGSize(width: collectionView?.bounds.width ?? 0, height: Constants.itemHeight)
            }
            
            let lastAttribute = attributes.max { a, b in
                a.frame.maxY < b.frame.maxY
            }!
            
            let height = lastAttribute.frame.maxY + sectionInset.bottom
            let width = collectionView?.bounds.width ?? 0
            
            return CGSize(width: width, height: height)
        }
        
        override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
            return cachedAttributes?.filter { $0.frame.intersects(rect) }
        }
        
        override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
            return cachedAttributes?.first { $0.indexPath == indexPath }
        }
        
        override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
            return true
        }
        
        private func collectionView(_ collectionView: UICollectionView, sizeForItemAt indexPath: IndexPath) -> CGSize {
            guard let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout else {
                return CGSize(width: 100, height: Constants.itemHeight)
            }
            
            return delegate.collectionView?(collectionView, layout: self, sizeForItemAt: indexPath)
                ?? CGSize(width: 100, height: Constants.itemHeight)
        }
    }
    
    private let questionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(AppFont.regular, size: 16)
        label.textColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var flowLayout = AnswersFlowLayout()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(AnswerCell.self, forCellWithReuseIdentifier: "AnswerCell")
        collectionView.register(PlusCell.self, forCellWithReuseIdentifier: "PlusCell")
        collectionView.isScrollEnabled = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.allowsMultipleSelection = true
        return collectionView
    }()
    
    private lazy var textEntryView: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.unselectedColor
        view.layer.cornerRadius = Constants.itemHeight/2
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.appFont(AppFont.regular, size: 14)
        textField.textColor = .white
        textField.tintColor = .white
        textField.delegate = self
        textField.returnKeyType = .done
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private var answers: [String] = []
    private var selectedAnswers: Set<String> = []
    private var onAnswerSelected: (String) -> Void
    private var textEntryWidthConstraint: NSLayoutConstraint?
    private var collectionViewHeightConstraint: NSLayoutConstraint?
    
    func setupAccessibilityIdentifiers() {
        accessibilityIdentifier = "questionView_\(tag)"
        
        questionLabel.accessibilityIdentifier = "questionLabel_\(tag)"
        
        textEntryView.accessibilityIdentifier = "textEntryView_\(tag)"
        textField.accessibilityIdentifier = "answerTextField_\(tag)"
        
        collectionView.accessibilityIdentifier = "answerCollectionView_\(tag)"
    }

    // MARK: - Initialization
    
    init(question: String, onAnswerSelected: @escaping (String) -> Void) {
        self.onAnswerSelected = onAnswerSelected
        super.init(frame: .zero)
        
        setupUI()
        questionLabel.text = question
        setupAccessibilityIdentifiers()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        addSubview(questionLabel)
        addSubview(collectionView)
        questionLabel.accessibilityIdentifier = "questionLabel_\(tag)"
        setupTextEntryView()
        
        collectionViewHeightConstraint = collectionView.heightAnchor.constraint(equalToConstant: Constants.itemHeight)
        collectionViewHeightConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            questionLabel.topAnchor.constraint(equalTo: topAnchor),
            questionLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            questionLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            collectionView.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 12),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),

            bottomAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 8)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOutside))
        tapGesture.cancelsTouchesInView = false
        addGestureRecognizer(tapGesture)
    }
    
    private func setupTextEntryView() {
        addSubview(textEntryView)
        textEntryView.addSubview(textField)
        
        textEntryWidthConstraint = textEntryView.widthAnchor.constraint(equalToConstant: 150)
        
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: textEntryView.leadingAnchor, constant: Constants.horizontalPadding),
            textField.trailingAnchor.constraint(equalTo: textEntryView.trailingAnchor, constant: -Constants.horizontalPadding),
            textField.centerYAnchor.constraint(equalTo: textEntryView.centerYAnchor),
            
            textEntryView.leadingAnchor.constraint(equalTo: leadingAnchor),
            textEntryView.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 12),
            textEntryView.heightAnchor.constraint(equalToConstant: Constants.itemHeight)
        ])
        
        textEntryWidthConstraint?.isActive = true
    }
    
    func configure(with answers: [String]) {
        self.answers = answers
        collectionView.reloadData()
        
        DispatchQueue.main.async { [weak self] in
            self?.updateCollectionViewHeight()
        }
    }
    
    private func updateCollectionViewHeight() {
        guard !isUpdatingHeight else { return }
        isUpdatingHeight = true
        
        collectionView.layoutIfNeeded()
        
        let height = collectionView.collectionViewLayout.collectionViewContentSize.height
        
        collectionViewHeightConstraint?.constant = max(height, Constants.itemHeight)
        
        isUpdatingHeight = false
        
        setNeedsLayout()
    }
    
    private var isUpdatingHeight = false
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !isUpdatingHeight && collectionView.frame.width > 0 {
            DispatchQueue.main.async { [weak self] in
                self?.updateCollectionViewHeight()
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func handleTapOutside() {
        if textField.isFirstResponder {
            hideTextEntry()
        }
    }
    
    private func showTextEntry() {
        textEntryView.isHidden = false
        textField.becomeFirstResponder()
        collectionView.isHidden = true
    }
    
    private func hideTextEntry() {
        if let text = textField.text, !text.isEmpty {
            addNewAnswer(text)
        }
        
        textEntryView.isHidden = true
        textField.text = nil
        textField.resignFirstResponder()
        collectionView.isHidden = false
    }
    
    private func addNewAnswer(_ answer: String) {
        if !answers.contains(answer) {
            answers.append(answer)
            toggleAnswerSelection(answer)
            collectionView.reloadData()
            updateCollectionViewHeight()
        }
    }
    
    private func toggleAnswerSelection(_ answer: String) {
        if selectedAnswers.contains(answer) {
            selectedAnswers.remove(answer)
        } else {
            selectedAnswers.insert(answer)
        }
        
        let selectedAnswersString = selectedAnswers.joined(separator: ", ")
        onAnswerSelected(selectedAnswersString)
    }
    
    // MARK: - Cell Classes
    
    class AnswerCell: UICollectionViewCell {
        let label: UILabel = {
            let label = UILabel()
            label.font = UIFont.appFont(AppFont.regular, size: 16)
            label.textColor = .white
            label.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = 1
            label.lineBreakMode = .byTruncatingTail
            label.textAlignment = .center
            return label
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            contentView.layer.cornerRadius = Constants.itemHeight/2
            contentView.backgroundColor = Constants.unselectedColor
            
            contentView.addSubview(label)
            
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horizontalPadding),
                label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.horizontalPadding),
                label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                contentView.heightAnchor.constraint(equalToConstant: Constants.itemHeight)
            ])
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func configure(with answer: String, isSelected: Bool) {
            label.text = answer
            contentView.backgroundColor = isSelected ? Constants.selectedColor : Constants.unselectedColor
        }
    }
    
    class PlusCell: UICollectionViewCell {
        private let plusButton: UIButton = {
            let button = UIButton(type: .system)
            button.setImage(UIImage(systemName: "plus"), for: .normal)
            button.tintColor = .white
            button.translatesAutoresizingMaskIntoConstraints = false
            button.isUserInteractionEnabled = false
            return button
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            contentView.backgroundColor = Constants.unselectedColor
            contentView.layer.cornerRadius = Constants.plusButtonSize/2
            
            contentView.addSubview(plusButton)
            
            NSLayoutConstraint.activate([
                plusButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                plusButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                contentView.widthAnchor.constraint(equalToConstant: Constants.plusButtonSize),
                contentView.heightAnchor.constraint(equalToConstant: Constants.plusButtonSize)
            ])
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

// MARK: - UICollectionView Delegate & DataSource

extension QuestionView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return answers.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item < answers.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AnswerCell", for: indexPath) as! AnswerCell
            let answer = answers[indexPath.item]
            cell.configure(with: answer, isSelected: selectedAnswers.contains(answer))
            
            cell.accessibilityIdentifier = "answerCell_\(tag)_\(indexPath.item)"
            cell.label.accessibilityIdentifier = "answerCellLabel_\(tag)_\(indexPath.item)"
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlusCell", for: indexPath)
            cell.accessibilityIdentifier = "plusCell_\(tag)"
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        
        if indexPath.item < answers.count {
            let answer = answers[indexPath.item]
            toggleAnswerSelection(answer)
            collectionView.reloadItems(at: [indexPath])
        } else {
            showTextEntry()
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension QuestionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.bounds.width - 16
        
        if indexPath.item < answers.count {
            let answer = answers[indexPath.item]
            
            let attributes = [NSAttributedString.Key.font: UIFont.appFont(AppFont.regular, size: 17)]
            let textSize = (answer as NSString).size(withAttributes: attributes)
            
            var cellWidth = max(textSize.width + (Constants.horizontalPadding * 2), Constants.minWidth)
            
            cellWidth = min(cellWidth, availableWidth)
            
            if textSize.width > availableWidth - (Constants.horizontalPadding * 2) {
                cellWidth = availableWidth
            }
            
            return CGSize(width: cellWidth, height: Constants.itemHeight)
        } else {
            return CGSize(width: Constants.plusButtonSize, height: Constants.plusButtonSize)
        }
    }
}

// MARK: - UITextField Delegate

extension QuestionView: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text = textField.text else { return }
        
        let attributes = [NSAttributedString.Key.font: textField.font ?? UIFont.appFont(AppFont.regular, size: 14)]
        let textWidth = (text as NSString).size(withAttributes: attributes).width
        let newWidth = max(textWidth + (Constants.horizontalPadding * 2), 120)
        
        let maxWidth = bounds.width - 32
        textEntryWidthConstraint?.constant = min(newWidth, maxWidth)
        
        UIView.animate(withDuration: 0.2) {
            self.layoutIfNeeded()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hideTextEntry()
        return true
    }
}
