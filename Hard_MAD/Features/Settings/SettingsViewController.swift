//
//  SettingsViewController.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//

import UIKit

final class SettingsViewController: UIViewController {
    private let viewModel: BaseViewModelProtocol
    
    init(viewModel: BaseViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        title = "Settings"
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
    }
}
