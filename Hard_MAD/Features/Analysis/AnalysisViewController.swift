//
//  AnalysisViewController.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//

import UIKit

final class AnalysisViewController: UIViewController {
    private let viewModel: AnalysisViewModelProtocol
    
    init(viewModel: AnalysisViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        title = "Analysis"
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
    }
}
