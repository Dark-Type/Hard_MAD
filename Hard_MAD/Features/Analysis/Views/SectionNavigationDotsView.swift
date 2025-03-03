//
//  SectionNavigationDotsView.swift
//  Hard_MAD
//
//  Created by dark type on 03.03.2025.
//

import UIKit

final class SectionNavigationDotsView: UIView {
    weak var delegate: NavigationDotsDelegate?
    
    private var selectedIndex: Int = 0
    private var dotViews: [UIView] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        for i in 0 ..< 4 {
            let dot = createDot()
            addSubview(dot)
            dotViews.append(dot)
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dotTapped(_:)))
            dot.addGestureRecognizer(tapGesture)
            dot.tag = i
            dot.isUserInteractionEnabled = true
        }
        
        updateSelectedDot()
    }
    
    private func createDot() -> UIView {
        let dot = UIView()
        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.backgroundColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1)
        dot.layer.cornerRadius = 3
        dot.widthAnchor.constraint(equalToConstant: 6).isActive = true
        dot.heightAnchor.constraint(equalToConstant: 6).isActive = true
        return dot
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let dotSpacing: CGFloat = 10
        let stackHeight = CGFloat(dotViews.count - 1) * dotSpacing + 6
        let startY = (bounds.height - stackHeight)/2
        
        for (index, dot) in dotViews.enumerated() {
            dot.center = CGPoint(
                x: bounds.width - (dot.bounds.width/2),
                y: startY + CGFloat(index) * dotSpacing
            )
        }
    }
    
    func setSelectedSection(_ index: Int, animated: Bool = true) {
        guard index >= 0 && index < dotViews.count else { return }
        selectedIndex = index
        updateSelectedDot(animated: animated)
    }
    
    private func updateSelectedDot(animated: Bool = false) {
        for (index, dot) in dotViews.enumerated() {
            let isSelected = index == selectedIndex
            
            if animated {
                UIView.animate(withDuration: 0.2) {
                    dot.backgroundColor = isSelected ? .white : UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1)
                }
            } else {
                dot.backgroundColor = isSelected ? .white : UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1)
            }
        }
    }
    
    @objc private func dotTapped(_ gesture: UITapGestureRecognizer) {
        guard let dot = gesture.view else { return }
        let index = dot.tag
        
        selectedIndex = index
        updateSelectedDot(animated: true)
        delegate?.navigationDots(self, didSelectSectionAt: index)
    }
}
