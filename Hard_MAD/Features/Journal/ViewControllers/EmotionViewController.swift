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
    
    // MARK: - Properties
    
    private var emotions: [Emotion] = Emotion.allCases + Emotion.allCases + [Emotion.anxious, Emotion.anxious, Emotion.anxious, Emotion.anxious]
    private var selectedIndex: IndexPath?
    private var panGesture: UIPanGestureRecognizer!
    private var didSetInitialPosition = false
    private var displayLink: CADisplayLink?
    
    private var initialGridCenter: CGPoint?
    private var currentGridOffset = CGPoint.zero
    private var targetGridOffset = CGPoint.zero
    
    private var animationTargets: [IndexPath: CATransform3D] = [:]
    private var isAnimating = false
    
    private var pushDistance: CGFloat {
        guard let layout = emotionsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        else {
            return 20.0
        }
        let itemSize = CGFloat(layout.itemSize.width)
        let normalRadius = itemSize / 2
        let expandedRadius = normalRadius * scaleMultiplier
        return (expandedRadius - normalRadius) + 10.0
    }
    
    private let scaleMultiplier: CGFloat = 1.5
    
    private let backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "goBack"), for: .normal)
        button.tintColor = .systemBlue
        return button
    }()
    
    private let gridContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = false
        return view
    }()
    
    private lazy var emotionsCollectionView: UICollectionView = {
        let layout = createGridLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(EmotionCell.self, forCellWithReuseIdentifier: "EmotionCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isScrollEnabled = false
        collectionView.clipsToBounds = false
        return collectionView
    }()
    
    private let bottomViewContainer = UIView()
    private let bottomContentLayer = CALayer()
    private var bottomViewTitle = ""
    private var bottomViewDescription = ""
    private var bottomViewTitleColor = UIColor.white
    private var bottomViewIsActive = false
    
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
        setupDisplayLink()
        setupGestures()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        displayLink?.isPaused = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        displayLink?.isPaused = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard !didSetInitialPosition else { return }
        didSetInitialPosition = true
        
        initialGridCenter = gridContainerView.center
        
        let bottomHeight: CGFloat = 80
        let extraSpacing: CGFloat = 40
        let topInset: CGFloat = view.safeAreaInsets.top + 20
        let bottomSpace = bottomHeight + extraSpacing + view.safeAreaInsets.bottom
        
        let availableHeight = view.bounds.height - topInset - bottomSpace
        let gridCenterY = topInset + (availableHeight / 2)
        
        gridContainerView.center.y = gridCenterY
        
        setupBottomView()
        
        DispatchQueue.main.async {
            self.findAndSelectCellClosestToCenter()
        }
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .black
        view.clipsToBounds = false
        
        view.addSubview(backButton)
        
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        view.addSubview(gridContainerView)
        gridContainerView.addSubview(emotionsCollectionView)
        
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40),
            
            gridContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            gridContainerView.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            gridContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.4),
            gridContainerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.7),
            
            emotionsCollectionView.centerXAnchor.constraint(equalTo: gridContainerView.centerXAnchor),
            emotionsCollectionView.centerYAnchor.constraint(equalTo: gridContainerView.centerYAnchor),
            emotionsCollectionView.widthAnchor.constraint(equalTo: gridContainerView.widthAnchor, multiplier: 0.85),
            emotionsCollectionView.heightAnchor.constraint(equalTo: gridContainerView.heightAnchor, multiplier: 0.85)
        ])
        
        view.addSubview(bottomViewContainer)
        view.bringSubviewToFront(backButton)
    }
    
    private func setupDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkTick))
        displayLink?.preferredFrameRateRange = CAFrameRateRange(minimum: 60, maximum: 120)
        displayLink?.add(to: .main, forMode: .common)
        displayLink?.isPaused = true
    }
    
    @objc private func displayLinkTick() {
        updateAnimations()
    }
    
    private func updateAnimations() {
        guard isAnimating else {
            return
        }
        
        var allCompleted = true
        
        for (indexPath, targetTransform) in animationTargets {
            guard let cell = emotionsCollectionView.cellForItem(at: indexPath) else { continue }
            
            let currentTransform = cell.layer.transform
            
            let step: CGFloat = 0.15
            
            let newTransform = CATransform3DInterpolate(
                currentTransform,
                targetTransform,
                step
            )
            
            cell.layer.transform = newTransform
            
            let isComplete = isTransformNearlyEqual(newTransform, targetTransform)
            
            if !isComplete {
                allCompleted = false
            }
        }
        
        if allCompleted {
            isAnimating = false
        }
    }
    
    private func isTransformNearlyEqual(_ a: CATransform3D, _ b: CATransform3D) -> Bool {
        let threshold: CGFloat = 0.001
        
        if abs(a.m11 - b.m11) > threshold || abs(a.m22 - b.m22) > threshold {
            return false
        }
        
        if abs(a.m41 - b.m41) > threshold || abs(a.m42 - b.m42) > threshold {
            return false
        }
        
        return true
    }
    
    private func setupBottomView() {
        let containerFrame = CGRect(
            x: 24,
            y: view.bounds.height - view.safeAreaInsets.bottom - 96,
            width: view.bounds.width - 48,
            height: 80
        )
        bottomViewContainer.frame = containerFrame
        
        bottomContentLayer.frame = bottomViewContainer.bounds
        bottomContentLayer.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1).cgColor
        bottomContentLayer.cornerRadius = 40
        
        bottomViewContainer.layer.addSublayer(bottomContentLayer)
        
        updateBottomViewContent(emotion: nil, animated: false)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(bottomViewTapped))
        bottomViewContainer.addGestureRecognizer(tapGesture)
        bottomViewContainer.isUserInteractionEnabled = false
    }
    
    private func setupGestures() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGesture.maximumNumberOfTouches = 1
        gridContainerView.addGestureRecognizer(panGesture)
    }
    
    private func createGridLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        return layout
    }
    
    // MARK: - Button Actions
    
    @objc private func backButtonTapped() {
        displayLink?.isPaused = true
        
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Bottom View Rendering (Direct Layer Drawing)
    
    private func updateBottomViewContent(emotion: Emotion?, animated: Bool) {
        if let emotion = emotion {
            bottomViewTitle = emotion.rawValue
            bottomViewDescription = emotion.description
            bottomViewTitleColor = emotion.color
            bottomViewIsActive = true
            bottomViewContainer.isUserInteractionEnabled = true
        } else {
            bottomViewTitle = L10n.Emotions.title
            bottomViewDescription = ""
            bottomViewTitleColor = .white
            bottomViewIsActive = false
            bottomViewContainer.isUserInteractionEnabled = false
        }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        bottomContentLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        let titleLayer = CATextLayer()
        titleLayer.string = bottomViewTitle
        titleLayer.font = UIFont.appFont(AppFont.regular, size: 12)
        titleLayer.fontSize = 12
        titleLayer.truncationMode = .none
        titleLayer.foregroundColor = bottomViewTitleColor.cgColor
        titleLayer.frame = CGRect(x: 25, y: 20, width: bottomViewContainer.bounds.width - 80, height: 40)
        titleLayer.alignmentMode = .left
        titleLayer.contentsScale = UIScreen.main.scale
        bottomContentLayer.addSublayer(titleLayer)
        
        if !bottomViewDescription.isEmpty {
            let descriptionLayer = CATextLayer()
            descriptionLayer.string = bottomViewDescription
            descriptionLayer.font = UIFont.appFont(AppFont.regular, size: 12)
            descriptionLayer.fontSize = 12
            descriptionLayer.foregroundColor = UIColor.white.cgColor
            descriptionLayer.frame = CGRect(x: 25, y: 35, width: bottomViewContainer.bounds.width - 80, height: 40)
            descriptionLayer.alignmentMode = .left
            descriptionLayer.contentsScale = UIScreen.main.scale
            descriptionLayer.isWrapped = true
            bottomContentLayer.addSublayer(descriptionLayer)
        }
        
        let imageLayer = CALayer()
        
        let containerHeight = bottomViewContainer.bounds.height
        let imageSize = containerHeight * 0.75
        let yOffset = (containerHeight - imageSize) / 2
        
        imageLayer.frame = CGRect(
            x: bottomViewContainer.bounds.width - imageSize - 12,
            y: yOffset,
            width: imageSize,
            height: imageSize
        )
        
        let imageName = bottomViewIsActive ? "goForwardActive" : "goForwardInactive"
        imageLayer.contents = UIImage(named: imageName)?.cgImage
        imageLayer.contentsGravity = .resizeAspect
        bottomContentLayer.addSublayer(imageLayer)
        
        CATransaction.commit()
    }
    
    // MARK: - Action Handlers
    
    @objc private func bottomViewTapped() {
        guard let selectedIndex = selectedIndex else { return }
        let emotion = emotions[selectedIndex.item]
        recordBuilder.setEmotion(emotion)
        
        displayLink?.isPaused = true
        
        Task {
            await onEmotionSelected?()
        }
    }
    
    // MARK: - Gesture Handlers
    
    @objc private func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let initialCenter = initialGridCenter else { return }
        
        switch gestureRecognizer.state {
        case .began:
            targetGridOffset = CGPoint(
                x: gridContainerView.center.x - initialCenter.x,
                y: gridContainerView.center.y - initialCenter.y
            )
            currentGridOffset = targetGridOffset
            
        case .changed:
            let translation = gestureRecognizer.translation(in: view)
            
            let dampingFactor: CGFloat = 0.35
            let dampedTranslation = CGPoint(
                x: translation.x * dampingFactor,
                y: translation.y * dampingFactor
            )
            
            let newCenter = CGPoint(
                x: initialCenter.x + currentGridOffset.x + dampedTranslation.x,
                y: initialCenter.y + currentGridOffset.y + dampedTranslation.y
            )
            
            let gridContentSize = calculateGridContentSize()

            let maxHorizontalOffset = min(gridContentSize.width * 0.35, 250)
            let maxVerticalOffset = min(gridContentSize.height * 0.6, 300)
            
            let limitedX = min(max(newCenter.x, initialCenter.x - maxHorizontalOffset), initialCenter.x + maxHorizontalOffset)
            let limitedY = min(max(newCenter.y, initialCenter.y - maxVerticalOffset), initialCenter.y + maxVerticalOffset)
            
            gridContainerView.center = CGPoint(x: limitedX, y: limitedY)
            targetGridOffset = CGPoint(
                x: limitedX - initialCenter.x,
                y: limitedY - initialCenter.y
            )
            currentGridOffset = targetGridOffset
            
            findAndSelectCellClosestToCenter(immediateSelection: true)
            
        case .ended, .cancelled:
            targetGridOffset = CGPoint(
                x: gridContainerView.center.x - initialCenter.x,
                y: gridContainerView.center.y - initialCenter.y
            )
            currentGridOffset = targetGridOffset
            
            findAndSelectCellClosestToCenter(immediateSelection: true)
            
        default:
            break
        }
    }

    private func calculateGridContentSize() -> CGSize {
        let cellCount = emotions.count
        let gridSize = 4
        let rowCount = (cellCount + gridSize - 1) / gridSize
        
        let cellWidth: CGFloat = 100
        let spacing: CGFloat = 5
        
        let totalWidth = CGFloat(gridSize) * (cellWidth + spacing)
        let totalHeight = CGFloat(rowCount) * (cellWidth + spacing)
        
        return CGSize(width: totalWidth, height: totalHeight)
    }
    
    // MARK: - Selection / Layout
    
    private func findAndSelectCellClosestToCenter(immediateSelection: Bool = false) {
        let screenCenter = view.center
        let collectionViewPoint = emotionsCollectionView.convert(screenCenter, from: view)
        
        var closestDistance: CGFloat = .greatestFiniteMagnitude
        var closestIndexPath: IndexPath?
        
        for cell in emotionsCollectionView.visibleCells {
            let cellCenter = cell.center
            let distance = hypot(cellCenter.x - collectionViewPoint.x, cellCenter.y - collectionViewPoint.y)
            
            if distance < closestDistance {
                closestDistance = distance
     
                closestIndexPath = emotionsCollectionView.indexPath(for: cell)
            }
        }
        
        let selectionThreshold: CGFloat = 120
        
        if closestDistance <= selectionThreshold, let indexPath = closestIndexPath {
            if indexPath == selectedIndex { return }
            
            updateSelection(at: indexPath)
            
            calculateAndApplyCellTransforms(selectedIndex: indexPath)
        } else if closestDistance > selectionThreshold && selectedIndex != nil {
            deselectCurrentEmotion()
        }
    }
    
    private func deselectCurrentEmotion() {
        if let selectedIndex = selectedIndex,
           let cell = emotionsCollectionView.cellForItem(at: selectedIndex) as? EmotionCell
        {
            cell.setSelected(false)
        }
        
        selectedIndex = nil
        
        animationTargets.removeAll()
        for indexPath in emotionsCollectionView.indexPathsForVisibleItems {
            animationTargets[indexPath] = CATransform3DIdentity
        }
        
        isAnimating = true
        displayLink?.isPaused = false
        updateBottomViewContent(emotion: nil, animated: false)
    }
    
    private func calculateAndApplyCellTransforms(selectedIndex: IndexPath) {
        let selectedItemPosition = selectedIndex.item
        
        let gridSize = 4
        let selectedRow = selectedItemPosition / gridSize
        let selectedCol = selectedItemPosition % gridSize
        
        animationTargets.removeAll()
        
        for indexPath in emotionsCollectionView.indexPathsForVisibleItems {
            let itemPosition = indexPath.item
            
            if indexPath == selectedIndex {
                animationTargets[indexPath] = CATransform3DMakeScale(scaleMultiplier, scaleMultiplier, 1.0)
            } else {
                let cellRow = itemPosition / gridSize
                let cellCol = itemPosition % gridSize
                let rowDiff = cellRow - selectedRow
                let colDiff = cellCol - selectedCol
                
                if rowDiff == 0 || colDiff == 0 {
                    let rowDirection = rowDiff > 0 ? 1 : (rowDiff < 0 ? -1 : 0)
                    let colDirection = colDiff > 0 ? 1 : (colDiff < 0 ? -1 : 0)
                    let distance = abs(rowDiff) + abs(colDiff)
                    
                    let verticalMultiplier = rowDiff != 0 ? 1.2 : 1.0
                    let basePushStrength = pushDistance * verticalMultiplier
                    
                    let pushFalloff: CGFloat
                    switch distance {
                    case 1: pushFalloff = 1.0
                    case 2: pushFalloff = 0.7
                    case 3: pushFalloff = 0.4
                    default: pushFalloff = 0.2
                    }
                    
                    var progressivePush: CGFloat = 0
                    if distance > 1 {
                        progressivePush = basePushStrength * 0.1 * CGFloat(distance - 1)
                    }
                    
                    let pushStrength = (basePushStrength * pushFalloff) + progressivePush
                    let translateX = CGFloat(colDirection) * pushStrength
                    let translateY = CGFloat(rowDirection) * pushStrength
                    
                    let scaleFactor = 1.0 - (0.01 * CGFloat(min(distance, 3)))
                    
                    var transform = CATransform3DIdentity
                    transform = CATransform3DTranslate(transform, translateX, translateY, 0)
                    transform = CATransform3DScale(transform, scaleFactor, scaleFactor, 1.0)
                    
                    animationTargets[indexPath] = transform
                } else {
                    animationTargets[indexPath] = CATransform3DIdentity
                }
            }
        }
        
        isAnimating = true
        displayLink?.isPaused = false
    }
    
    private func updateSelection(at indexPath: IndexPath) {
        let previousSelectedIndex = selectedIndex
        selectedIndex = indexPath
        let emotion = emotions[indexPath.item]
        
        title = emotion.rawValue
        
        if let previousCell = previousSelectedIndex.flatMap({ self.emotionsCollectionView.cellForItem(at: $0) }) as? EmotionCell {
            previousCell.setSelected(false)
        }
        
        if let selectedCell = emotionsCollectionView.cellForItem(at: indexPath) as? EmotionCell {
            selectedCell.setSelected(true)
        }
        
        updateBottomViewContent(emotion: emotion, animated: false)
    }
}

// MARK: - Transform Helper Functions

extension EmotionViewController {
    private func CATransform3DInterpolate(_ a: CATransform3D, _ b: CATransform3D, _ t: CGFloat) -> CATransform3D {
        var result = CATransform3DIdentity

        let m1 = a.m11
        let m2 = b.m11

        let scale = m1 + (m2 - m1) * t
        
        let tx1 = a.m41
        let ty1 = a.m42
        let tx2 = b.m41
        let ty2 = b.m42
        
        let tx = tx1 + (tx2 - tx1) * t
        let ty = ty1 + (ty2 - ty1) * t
        
        result = CATransform3DMakeTranslation(tx, ty, 0)
        result = CATransform3DScale(result, scale, scale, 1.0)
        
        return result
    }
}

// MARK: - UICollectionView DataSource & Delegate

extension EmotionViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        emotions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmotionCell", for: indexPath) as! EmotionCell
        let emotion = emotions[indexPath.item]
        cell.configure(with: emotion)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let totalSpacing = 3 * 5
        let sectionInsets = 10
        let availableWidth = collectionView.bounds.width - CGFloat(totalSpacing) - CGFloat(sectionInsets)
        
        let itemWidth = floor(availableWidth / 4)
        let minSize: CGFloat = 100
        let size = max(itemWidth, minSize)
        return CGSize(width: size, height: size)
    }
}

// MARK: - Gesture Recognizer Delegate

extension EmotionViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return true
    }
}
