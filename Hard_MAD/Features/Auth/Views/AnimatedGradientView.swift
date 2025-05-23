//
//  AnimatedGradientView.swift
//  Hard_MAD
//
//  Created by dark type on 28.02.2025.
//

import UIKit

final class RadialGradientBackgroundView: UIView {
    // MARK: - Properties

    private var topLeftColor: UIColor
    private var topRightColor: UIColor
    private var bottomRightColor: UIColor
    private var bottomLeftColor: UIColor

    private var animationDuration: CFTimeInterval
    private var cornerGradients: [CAGradientLayer] = []
    private var blurEffectView: UIVisualEffectView?
    private var gradientContainer: UIView!

    private var displayLink: CADisplayLink?
    private var startTime: CFTimeInterval = 0

    // MARK: - Initialization

    init(
        topLeftColor: UIColor,
        topRightColor: UIColor,
        bottomRightColor: UIColor,
        bottomLeftColor: UIColor,
        animationDuration: CFTimeInterval = 15.0
    ) {
        self.topLeftColor = topLeftColor
        self.topRightColor = topRightColor
        self.bottomRightColor = bottomRightColor
        self.bottomLeftColor = bottomLeftColor
        self.animationDuration = animationDuration
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        self.topLeftColor = .black
        self.topRightColor = .black
        self.bottomRightColor = .black
        self.bottomLeftColor = .black
        self.animationDuration = 15.0
        super.init(coder: coder)
        setupView()
    }

    // MARK: - Setup

    private func setupView() {
        backgroundColor = UIColor(white: 0.1, alpha: 1.0)

        gradientContainer = UIView(frame: bounds)
        gradientContainer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(gradientContainer)

        setupGradients()
        addBlurEffects()
        startAnimation()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientContainer.frame = bounds
        updateGradientFrames()
        blurEffectView?.frame = bounds
    }

    private func setupGradients() {
        let colors = [topLeftColor, topRightColor, bottomRightColor, bottomLeftColor]
        cornerGradients = []

        for color in colors {
            let gradientLayer = createRadialGradient(with: color)
            gradientContainer.layer.addSublayer(gradientLayer)
            cornerGradients.append(gradientLayer)
        }

        updateGradientFrames()
    }

    private func addBlurEffects() {
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.alpha = 0.2

        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyView.frame = blurView.bounds
        vibrancyView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.contentView.addSubview(vibrancyView)

        let maskLayer = CAGradientLayer()
        maskLayer.frame = bounds
        maskLayer.type = .radial
        maskLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.white.withAlphaComponent(0.2).cgColor,
            UIColor.white.withAlphaComponent(0.5).cgColor,
            UIColor.white.withAlphaComponent(0.9).cgColor,
            UIColor.white.withAlphaComponent(0.5).cgColor,
            UIColor.white.withAlphaComponent(0.2).cgColor,
            UIColor.clear.cgColor
        ]
        maskLayer.locations = [0.0, 0.4, 0.55, 0.7, 0.85, 0.95, 1.0]
        maskLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        maskLayer.endPoint = CGPoint(x: 1.0, y: 1.0)

        let maskView = UIView(frame: bounds)
        maskView.layer.addSublayer(maskLayer)
        maskView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        vibrancyView.contentView.addSubview(maskView)

        let boundaryBlurEffect = UIBlurEffect(style: .regular)
        let boundaryBlurView = UIVisualEffectView(effect: boundaryBlurEffect)
        boundaryBlurView.frame = bounds
        boundaryBlurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        boundaryBlurView.alpha = 0.3

        let boundaryMaskLayer = CAGradientLayer()
        boundaryMaskLayer.frame = bounds
        boundaryMaskLayer.type = .radial
        boundaryMaskLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.clear.cgColor,
            UIColor.white.cgColor,
            UIColor.white.cgColor,
            UIColor.clear.cgColor
        ]
        boundaryMaskLayer.locations = [0.0, 0.55, 0.65, 0.8, 1.0]
        boundaryMaskLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        boundaryMaskLayer.endPoint = CGPoint(x: 1.0, y: 1.0)

        let boundaryMaskView = UIView(frame: bounds)
        boundaryMaskView.layer.addSublayer(boundaryMaskLayer)
        boundaryMaskView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        boundaryBlurView.contentView.addSubview(boundaryMaskView)

        addSubview(blurView)
        addSubview(boundaryBlurView)
        blurEffectView = blurView
    }

    private func createRadialGradient(with color: UIColor) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.type = .radial
        gradient.colors = [
            color.cgColor,
            color.cgColor,
            color.withAlphaComponent(0.98).cgColor,
            color.withAlphaComponent(0.95).cgColor,
            color.withAlphaComponent(0.9).cgColor,
            color.withAlphaComponent(0.85).cgColor,
            color.withAlphaComponent(0.8).cgColor,
            color.withAlphaComponent(0.7).cgColor,
            color.withAlphaComponent(0.6).cgColor,
            color.withAlphaComponent(0.5).cgColor,
            color.withAlphaComponent(0.4).cgColor,
            color.withAlphaComponent(0.3).cgColor,
            color.withAlphaComponent(0.2).cgColor,
            color.withAlphaComponent(0.1).cgColor,
            color.withAlphaComponent(0.05).cgColor,
            UIColor.clear.cgColor
        ]
        gradient.locations = [0.0, 0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.85, 0.9, 0.95, 1.0]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.opacity = 0.9
        gradient.compositingFilter = "overlayBlendMode"
        return gradient
    }

    private func updateGradientFrames() {
        guard cornerGradients.count == 4 else { return }

        let width = bounds.width
        let height = bounds.height
        let gradientSize = max(width, height) * 1.5

        if displayLink != nil {
            let elapsedTime = CACurrentMediaTime() - startTime
            let normalizedTime = (elapsedTime.truncatingRemainder(dividingBy: animationDuration)) / animationDuration
            let angle = normalizedTime * 2 * .pi
            positionGradientsWithRotation(angle: angle, gradientSize: gradientSize)
        } else {
            positionGradientsWithRotation(angle: 0, gradientSize: gradientSize)
        }
    }

    private func positionGradientsWithRotation(angle: CGFloat, gradientSize: CGFloat) {
        let centerX = bounds.width / 2
        let centerY = bounds.height / 2
        let radius = sqrt(pow(centerX, 2) + pow(centerY, 2))

        for (i, gradient) in cornerGradients.enumerated() {
            let cornerBaseAngle = CGFloat(i) * (.pi / 2)
            let rotatedAngle = cornerBaseAngle + angle

            let gradientCenterX = centerX + radius * cos(rotatedAngle)
            let gradientCenterY = centerY + radius * sin(rotatedAngle)

            gradient.frame = CGRect(
                x: gradientCenterX - gradientSize / 2,
                y: gradientCenterY - gradientSize / 2,
                width: gradientSize,
                height: gradientSize
            )
        }
    }

    // MARK: - Animation

    private func startAnimation() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateAnimation))
        displayLink?.add(to: .current, forMode: .common)
        startTime = CACurrentMediaTime()
    }

    @objc private func updateAnimation() {
        let elapsedTime = CACurrentMediaTime() - startTime
        let normalizedTime = (elapsedTime.truncatingRemainder(dividingBy: animationDuration)) / animationDuration
        let angle = normalizedTime * 2 * .pi

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        let gradientSize = max(bounds.width, bounds.height) * 1.5
        positionGradientsWithRotation(angle: angle, gradientSize: gradientSize)
        CATransaction.commit()

        if let blurView = blurEffectView {
            for view in blurView.contentView.subviews {
                if let maskLayer = view.layer.sublayers?.first as? CAGradientLayer {
                    maskLayer.transform = CATransform3DMakeRotation(angle * 0.25, 0, 0, 1)
                }
            }
        }
    }

    // MARK: - Public Methods

    func updateColors(
        topLeft: UIColor? = nil,
        topRight: UIColor? = nil,
        bottomRight: UIColor? = nil,
        bottomLeft: UIColor? = nil
    ) {
        if let color = topLeft { topLeftColor = color }
        if let color = topRight { topRightColor = color }
        if let color = bottomRight { bottomRightColor = color }
        if let color = bottomLeft { bottomLeftColor = color }

        let newColors = [topLeftColor, topRightColor, bottomRightColor, bottomLeftColor]

        for (i, color) in newColors.enumerated() where i < cornerGradients.count {
            cornerGradients[i].colors = [
                color.cgColor,
                color.cgColor,
                color.withAlphaComponent(0.98).cgColor,
                color.withAlphaComponent(0.95).cgColor,
                color.withAlphaComponent(0.9).cgColor,
                color.withAlphaComponent(0.85).cgColor,
                color.withAlphaComponent(0.8).cgColor,
                color.withAlphaComponent(0.7).cgColor,
                color.withAlphaComponent(0.6).cgColor,
                color.withAlphaComponent(0.5).cgColor,
                color.withAlphaComponent(0.4).cgColor,
                color.withAlphaComponent(0.3).cgColor,
                color.withAlphaComponent(0.2).cgColor,
                color.withAlphaComponent(0.1).cgColor,
                color.withAlphaComponent(0.05).cgColor,
                UIColor.clear.cgColor
            ]
        }
    }

    func cleanup() {
        displayLink?.invalidate()
        displayLink = nil
    }
}
