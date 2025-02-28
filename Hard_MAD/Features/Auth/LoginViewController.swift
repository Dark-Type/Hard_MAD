//
//  LoginViewController.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//

import UIKit

final class LoginViewController: UIViewController {
    private let viewModel: LoginViewModel
    
    // MARK: - UI Components

    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Initialization

    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
       // FontUtils.printAvailableFonts()
        setupUI()
        bindViewModel()
    }
    
    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Login"
        
        view.addSubview(loginButton)
        
        NSLayoutConstraint.activate([
            loginButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            
            loginButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func bindViewModel() {
        viewModel.showLoadingIndicator = { [weak self] isLoading in
            self?.loginButton.isEnabled = !isLoading
            self?.loginButton.setTitle(isLoading ? "Loading..." : "Login", for: .normal)
        }
        
        viewModel.showError = { [weak self] message in
            let alert = UIAlertController(
                title: "Error",
                message: message,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
    }
    
    // MARK: - Actions

    @objc private func loginButtonTapped() {
        Task {
            await viewModel.login()
        }
    }
}
