//
//  LoginViewController.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//

import UIKit

final class LoginViewController: UIViewController {
    private let viewModel: LoginViewModel
    
    private var gradientBackgroundView: PerfectRadialGradientView!
    
    // MARK: - UI Components
    
    private lazy var welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.Auth.title
        label.font = UIFont.appFont(AppFont.fancy, size: 48)
        print(label.font ?? "font is nil")
        label.textColor = .black
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var loadingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .white
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        activityIndicator.startAnimating()
        return view
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.layer.cornerRadius = 40
           
        let containerView = UIView()
        containerView.isUserInteractionEnabled = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
           
        let imageView = UIImageView(image: UIImage(named: "apple"))
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false
           
        let titleLabel = UILabel()
        titleLabel.text = L10n.Auth.placeholder
        titleLabel.font = UIFont.appFont(AppFont.regular, size: 16)
        titleLabel.textColor = .black
        titleLabel.isUserInteractionEnabled = false
        
        let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel])
        stackView.spacing = 12
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.isUserInteractionEnabled = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
           
        containerView.addSubview(stackView)
        button.addSubview(containerView)
           
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 36),
            imageView.heightAnchor.constraint(equalToConstant: 36)
        ])
           
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
           
        NSLayoutConstraint.activate([
            containerView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 32),
            containerView.trailingAnchor.constraint(lessThanOrEqualTo: button.trailingAnchor, constant: -16)
        ])
           
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
        setupGradientBackground()
        setupUI()
        bindViewModel()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        gradientBackgroundView.cleanup()
    }
    
    // MARK: - Setup
    
    private func setupGradientBackground() {
        gradientBackgroundView = PerfectRadialGradientView(
            topLeftColor: GradientColors.Corner.fourth.color,
            topRightColor: GradientColors.Corner.third.color,
            bottomRightColor: GradientColors.Corner.second.color,
            bottomLeftColor: GradientColors.Corner.first.color,
            animationDuration: 15.0
        )
          
        gradientBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(gradientBackgroundView, at: 0)
          
        NSLayoutConstraint.activate([
            gradientBackgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            gradientBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradientBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gradientBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
      
    private func setupUI() {
        view.addSubview(welcomeLabel)
        view.addSubview(loginButton)
        view.addSubview(loadingView)
        
        welcomeLabel.accessibilityIdentifier = "welcome_label"
        loginButton.accessibilityIdentifier = "login_button"
           
      
        if let imageView = loginButton.subviews.first?.subviews.first as? UIImageView {
            imageView.accessibilityIdentifier = "login_apple_image"
        }
           
        if let titleLabel = loginButton.subviews.first?.subviews.compactMap({ $0 as? UILabel }).first {
            titleLabel.accessibilityIdentifier = "login_button_label"
        }
           
        loadingView.accessibilityIdentifier = "loading_view"
        
        NSLayoutConstraint.activate([
            welcomeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            welcomeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            welcomeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            loginButton.heightAnchor.constraint(equalToConstant: 80),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            loginButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -48),
            
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func bindViewModel() {
        viewModel.showLoadingIndicator = { [weak self] isLoading in
            self?.loadingView.isHidden = !isLoading
            self?.loginButton.isEnabled = !isLoading
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
