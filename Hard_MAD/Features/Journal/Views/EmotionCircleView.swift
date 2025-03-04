//
//  EmotionCircleView.swift
//  Hard_MAD
//
//  Created by dark type on 01.03.2025.
//
import UIKit

final class EmotionCircleView: UIView {
    // MARK: - Properties
    
    private let ringWidth: CGFloat = 30.0
    
    private let baseRingLayer = CAShapeLayer()
    
    private var progressLayers: [CAGradientLayer] = []
    
    private let rotationContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "addButton"), for: .normal)
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let addLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.Journal.Button.title
        label.font = UIFont.appFont(AppFont.regular, size: 14)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var lastEmotions: [Emotion] = []
    
    // MARK: - Action Closure

    var onAddButtonTapped: (() -> Void)?
    
    // MARK: - Initialization

    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupLayers()
        
        if !lastEmotions.isEmpty {
            configureProgressRings(with: lastEmotions)
        } else {
            configureDefaultProgressRing()
        }
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil {
            startRotationAnimation()
        }
    }
    
    // MARK: - UI Setup

    private func setupUI() {
        backgroundColor = .clear
        
        addSubview(rotationContainerView)
        
        addSubview(addButton)
        addSubview(addLabel)
        addButton.accessibilityIdentifier = "newEntryButton"

        NSLayoutConstraint.activate([
            rotationContainerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            rotationContainerView.topAnchor.constraint(equalTo: topAnchor),
            rotationContainerView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.93),
            rotationContainerView.heightAnchor.constraint(equalTo: rotationContainerView.widthAnchor),
            
            addButton.centerXAnchor.constraint(equalTo: rotationContainerView.centerXAnchor),
            addButton.centerYAnchor.constraint(equalTo: rotationContainerView.centerYAnchor, constant: -15),
            addButton.widthAnchor.constraint(equalTo: rotationContainerView.widthAnchor, multiplier: 0.2),
            addButton.heightAnchor.constraint(equalTo: addButton.widthAnchor),
            
            addLabel.centerXAnchor.constraint(equalTo: rotationContainerView.centerXAnchor),
            addLabel.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 8),
            addLabel.bottomAnchor.constraint(lessThanOrEqualTo: rotationContainerView.bottomAnchor, constant: -20),
            
            rotationContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        configureDefaultProgressRing()
    }
    
    private func setupLayers() {
        if baseRingLayer.superlayer == nil {
            let size = rotationContainerView.bounds.size
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = min(size.width, size.height) / 2 - ringWidth / 2
            
            baseRingLayer.path = UIBezierPath(arcCenter: center,
                                              radius: radius,
                                              startAngle: 0,
                                              endAngle: 2 * .pi,
                                              clockwise: true).cgPath
            baseRingLayer.fillColor = nil
            baseRingLayer.strokeColor = UIColor(red: 26 / 255, green: 26 / 255, blue: 26 / 255, alpha: 1.0).cgColor
            baseRingLayer.lineWidth = ringWidth
            baseRingLayer.frame = rotationContainerView.bounds
            rotationContainerView.layer.addSublayer(baseRingLayer)
        }
    }
    
    // MARK: - Configuration
    
    func configure(with emotions: [Emotion]) {
        lastEmotions = emotions
        
        rotationContainerView.layer.removeAllAnimations()
        
        for layer in progressLayers {
            layer.removeFromSuperlayer()
        }
        progressLayers.removeAll()
        
        if emotions.isEmpty {
            configureDefaultProgressRing()
        } else {
            configureProgressRings(with: emotions)
        }
        
        startRotationAnimation()
    }
    
    private func configureDefaultProgressRing() {
        let size = rotationContainerView.bounds.size
        if size.width <= 0 || size.height <= 0 {
            return
        }
        
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let radius = min(size.width, size.height) / 2 - ringWidth / 2
        
        let defaultGradientLayer = CAGradientLayer()
        defaultGradientLayer.frame = rotationContainerView.bounds
        
        defaultGradientLayer.colors = [
            UIColor(red: 26 / 255, green: 26 / 255, blue: 26 / 255, alpha: 0).cgColor, UIColor(red: 102 / 255, green: 102 / 255, blue: 102 / 255, alpha: 1.0).cgColor
        ]
        defaultGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        defaultGradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(arcCenter: center,
                                      radius: radius,
                                      startAngle: -.pi / 2,
                                      endAngle: .pi / 2,
                                      clockwise: true).cgPath
        maskLayer.fillColor = nil
        maskLayer.strokeColor = UIColor.white.cgColor
        maskLayer.lineWidth = ringWidth - 4
        maskLayer.lineCap = .round
        
        defaultGradientLayer.mask = maskLayer
        
        rotationContainerView.layer.addSublayer(defaultGradientLayer)
        progressLayers.append(defaultGradientLayer)
    }
    
    private func configureProgressRings(with emotions: [Emotion]) {
        let size = rotationContainerView.bounds.size
        if size.width <= 0 || size.height <= 0 {
            return
        }
        
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let radius = min(size.width, size.height) / 2 - ringWidth / 2
        
        if emotions.count == 1 {
            let emotion = emotions[0]
            let halfGradient = createGradientLayer(for: emotion, in: rotationContainerView.bounds)
            
            let maskLayer = CAShapeLayer()
            maskLayer.path = UIBezierPath(arcCenter: center,
                                          radius: radius,
                                          startAngle: -.pi / 2,
                                          endAngle: .pi / 2,
                                          clockwise: true).cgPath
            maskLayer.fillColor = nil
            maskLayer.strokeColor = UIColor.white.cgColor
            maskLayer.lineWidth = ringWidth - 4
            maskLayer.lineCap = .round
            
            halfGradient.mask = maskLayer
            rotationContainerView.layer.addSublayer(halfGradient)
            progressLayers.append(halfGradient)
        } else if emotions.count >= 2 {
            let firstEmotion = emotions[0]
            let firstHalfGradient = createGradientLayer(for: firstEmotion, in: rotationContainerView.bounds)
            
            let firstMaskLayer = CAShapeLayer()
            firstMaskLayer.path = UIBezierPath(arcCenter: center,
                                               radius: radius,
                                               startAngle: -.pi / 2,
                                               endAngle: .pi / 2,
                                               clockwise: true).cgPath
            firstMaskLayer.fillColor = nil
            firstMaskLayer.strokeColor = UIColor.white.cgColor
            firstMaskLayer.lineWidth = ringWidth - 4
            firstMaskLayer.lineCap = .butt
            
            firstHalfGradient.mask = firstMaskLayer
            rotationContainerView.layer.addSublayer(firstHalfGradient)
            progressLayers.append(firstHalfGradient)
            
            let secondEmotion = emotions[1]
            let secondHalfGradient = createGradientLayer(for: secondEmotion, in: rotationContainerView.bounds)
            
            let secondMaskLayer = CAShapeLayer()
            secondMaskLayer.path = UIBezierPath(arcCenter: center,
                                                radius: radius,
                                                startAngle: .pi / 2,
                                                endAngle: 1.5 * .pi,
                                                clockwise: true).cgPath
            secondMaskLayer.fillColor = nil
            secondMaskLayer.strokeColor = UIColor.white.cgColor
            secondMaskLayer.lineWidth = ringWidth - 4
            secondMaskLayer.lineCap = .butt
            
            secondHalfGradient.mask = secondMaskLayer
            rotationContainerView.layer.addSublayer(secondHalfGradient)
            progressLayers.append(secondHalfGradient)
        }
    }
    
    private func createGradientLayer(for emotion: Emotion, in bounds: CGRect) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        
        let colors = emotion.emotionType.gradientType
        gradientLayer.colors = [colors.start.cgColor, colors.end.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        return gradientLayer
    }
    
    // MARK: - Animation
    
    private func startRotationAnimation() {
        rotationContainerView.layer.removeAnimation(forKey: "rotationAnimation")
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = 0
        rotationAnimation.toValue = 2 * Double.pi
        rotationAnimation.duration = 5
        rotationAnimation.repeatCount = .infinity
        rotationAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        
        rotationContainerView.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
    
    @objc private func addButtonTapped() {
        onAddButtonTapped?()
    }
}
