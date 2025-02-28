//
//  AnalysisViewController.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//

import UIKit

final class AnalysisViewController: UIViewController {
    private let viewModel: BaseViewModelProtocol
    
    init(viewModel: BaseViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
 
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
    }
}
