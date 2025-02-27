//
//  EmotionViewController.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//

import UIKit

final class EmotionViewController: UIViewController {
    private let recordBuilder: RecordBuilder
    var onEmotionSelected: (@Sendable () async -> Void)?
    
    // MARK: - UI Components

    private lazy var emotionsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(EmotionCell.self, forCellWithReuseIdentifier: "EmotionCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    // MARK: - Initialization

    init(recordBuilder: RecordBuilder) {
        self.recordBuilder = recordBuilder
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup

    private func setupUI() {
        title = "How are you feeling?"
        view.backgroundColor = .systemBackground
        
        view.addSubview(emotionsCollectionView)
        
        NSLayoutConstraint.activate([
            emotionsCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emotionsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emotionsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            emotionsCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - UICollectionView DataSource & Delegate

extension EmotionViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        Emotion.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmotionCell", for: indexPath) as! EmotionCell
        let emotion = Emotion.allCases[indexPath.item]
        cell.configure(with: emotion)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let emotion = Emotion.allCases[indexPath.item]
        recordBuilder.setEmotion(emotion)
        Task {
            await onEmotionSelected?()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 20) / 2
        return CGSize(width: width, height: width)
    }
}
