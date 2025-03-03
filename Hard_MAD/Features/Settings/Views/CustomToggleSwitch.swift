//
//  CustomToggleSwitch.swift
//  Hard_MAD
//
//  Created by dark type on 03.03.2025.
//

import UIKit

class CustomToggleSwitch: UIControl {
    // MARK: - Properties
    
    private let thumbView = UIView()
    private let trackView = UIView()
    
    private let offTrackColor = UIColor.white
    
    private let onTrackColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
    private let thumbColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1)
    
    private let thumbSize: CGFloat = 20.0
    private let trackInsets: CGFloat = 5.0
    
    private var thumbLeadingConstraint: NSLayoutConstraint!
    private var thumbTrailingConstraint: NSLayoutConstraint!
    
    var isOn: Bool = false {
        didSet {
            updateUI()
        }
    }
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    // MARK: - UI Setup
    
    private func setupViews() {
        trackView.backgroundColor = offTrackColor
        trackView.layer.borderWidth = 2.0
        trackView.layer.borderColor = offTrackColor.cgColor
        trackView.layer.cornerRadius = 16
        trackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(trackView)
        
        thumbView.backgroundColor = thumbColor
        thumbView.layer.cornerRadius = thumbSize/2
        thumbView.translatesAutoresizingMaskIntoConstraints = false
        thumbView.layer.shadowColor = UIColor.black.cgColor
        thumbView.layer.shadowRadius = 1
        thumbView.layer.shadowOpacity = 0.2
        thumbView.layer.shadowOffset = CGSize(width: 0, height: 1)
        addSubview(thumbView)
        
        NSLayoutConstraint.activate([
            trackView.topAnchor.constraint(equalTo: topAnchor),
            trackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            trackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            trackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            thumbView.widthAnchor.constraint(equalToConstant: thumbSize),
            thumbView.heightAnchor.constraint(equalToConstant: thumbSize),
            thumbView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        thumbLeadingConstraint = thumbView.leadingAnchor.constraint(equalTo: trackView.leadingAnchor, constant: trackInsets)
        thumbTrailingConstraint = thumbView.trailingAnchor.constraint(equalTo: trackView.trailingAnchor, constant: -trackInsets)
        
        thumbLeadingConstraint.isActive = true
        thumbTrailingConstraint.isActive = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleState))
        addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions & Updates
    
    @objc private func toggleState() {
        isOn.toggle()
        sendActions(for: .valueChanged)
    }
    
    private func updateUI() {
        UIView.animate(withDuration: 0.2) {
            self.thumbLeadingConstraint.isActive = !self.isOn
            self.thumbTrailingConstraint.isActive = self.isOn
            
            self.trackView.backgroundColor = self.isOn ? self.onTrackColor : self.offTrackColor
            self.layoutIfNeeded()
        }
    }
    
    // MARK: - Size Requirements
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 51, height: 31)
    }
}
