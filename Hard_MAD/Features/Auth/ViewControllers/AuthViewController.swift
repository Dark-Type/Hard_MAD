//
//  LoginViewController.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//

import SnapKit
import UIKit
import WebKit

final class AuthViewController: UIViewController {
    // MARK: - Properties

    private let viewModel: AuthViewModel
    private let authState: AuthState
    private var gradientBackgroundView: RadialGradientBackgroundView!

    // MARK: - UI Components

    private let welcomeLabel = UILabel()
    private let loginButton = UIButton()
    private let loadingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.isHidden = true
        view.accessibilityIdentifier = Accessibility.loadingView

        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .white
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { $0.center.equalToSuperview() }
        return view
    }()

    // MARK: - Init

    init(viewModel: AuthViewModel, authState: AuthState) {
        self.viewModel = viewModel
        self.authState = authState
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        setupWelcomeLabel()
        setupLoginButton()
        setupLoadingView()
        bindViewModel()
        handleInitialAuthState()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        gradientBackgroundView.cleanup()
    }

    // MARK: — Flow Functions

    private func handleInitialAuthState() {
        if authState == AuthState.needsBiometry {
            presentBiometryFlow()
        }
        else if authState == AuthState.notLoggedIn {
            loginButton.isHidden = false
        }
    }

    private func presentBiometryFlow() {
        let biometryVC = BiometryViewController(
            reason: "Login",
            onSuccess: { [weak self] in
                self?.dismiss(animated: true) {
                    self?.viewModel.onLoginSuccess()
                }
            },
            onFailure: { [weak self] in
                self?.dismiss(animated: true) {
                    self?.presentRegularLogin()
                }
            }
        )
        present(biometryVC, animated: true)
    }

    private func presentRegularLogin() {
        let webVC = WebViewController(
            url: URL(string: "https://google.com")!,
            onDismiss: { [weak self] in
                print("Dismissed Successfully")
                Task { await self?.viewModel.loginWithApple() }
            }
        )
        webVC.presentationController?.delegate = webVC
        present(webVC, animated: true)
    }

    // MARK: - UI Setup

    private func setupGradientBackground() {
        gradientBackgroundView = RadialGradientBackgroundView(
            topLeftColor: GradientColors.Corner.fourth.color,
            topRightColor: GradientColors.Corner.third.color,
            bottomRightColor: GradientColors.Corner.second.color,
            bottomLeftColor: GradientColors.Corner.first.color,
            animationDuration: 15.0
        )
        view.insertSubview(gradientBackgroundView, at: 0)
        gradientBackgroundView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    private func setupWelcomeLabel() {
        welcomeLabel.text = L10n.Auth.title
        welcomeLabel.font = UIFont.appFont(AppFont.fancy, size: 48)
        welcomeLabel.textColor = .black
        welcomeLabel.numberOfLines = 2
        welcomeLabel.accessibilityIdentifier = Accessibility.welcomeLabel
        view.addSubview(welcomeLabel)
        welcomeLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(Layout.topInset)
            $0.left.right.equalToSuperview().inset(Layout.horizontalInset)
        }
    }

    private func setupLoginButton() {
        loginButton.backgroundColor = .white
        loginButton.layer.cornerRadius = 40
        loginButton.accessibilityIdentifier = Accessibility.loginButton

        let imageView = UIImageView(image: UIImage(named: Images.apple))
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false
        imageView.accessibilityIdentifier = Accessibility.loginAppleImage

        let titleLabel = UILabel()
        titleLabel.text = L10n.Auth.placeholder
        titleLabel.font = UIFont.appFont(AppFont.regular, size: 16)
        titleLabel.textColor = .black
        titleLabel.isUserInteractionEnabled = false
        titleLabel.accessibilityIdentifier = Accessibility.loginButtonLabel

        let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel])
        stackView.spacing = 12
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.isUserInteractionEnabled = false

        loginButton.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.left.equalToSuperview().offset(32)
            $0.right.lessThanOrEqualToSuperview().offset(-16)
        }

        view.addSubview(loginButton)
        loginButton.snp.makeConstraints {
            $0.height.equalTo(Layout.buttonHeight)
            $0.left.right.equalToSuperview().inset(Layout.horizontalInset)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(Layout.buttonBottomInset)
        }

        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    }

    private func setupLoadingView() {
        view.addSubview(loadingView)
        loadingView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    // MARK: - ViewModel Binding

    private func bindViewModel() {
        viewModel.showLoadingIndicator = { [weak self] isLoading in
            self?.loadingView.isHidden = !isLoading
            self?.loginButton.isEnabled = !isLoading
        }
        viewModel.showError = { [weak self] message in
            let alert = UIAlertController(
                title: L10n.Error.generic.localizedCapitalized,
                message: message,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: Locale.okTitle, style: .default))
            self?.present(alert, animated: true)
        }
    }

    // MARK: - Actions

    @objc private func loginButtonTapped() {
        presentRegularLogin()
        print("LoginButton tapped")
    }
}

// MARK: - Constants

private enum Layout {
    static let topInset: CGFloat = 24
    static let horizontalInset: CGFloat = 24
    static let buttonHeight: CGFloat = 80
    static let buttonBottomInset: CGFloat = 48
}

private enum Images {
    static let apple = "apple"
}

private enum Locale {
    static let okTitle = "OK"
}

private enum Accessibility {
    static let welcomeLabel = "welcome_label"
    static let loginButton = "login_button"
    static let loginAppleImage = "login_apple_image"
    static let loginButtonLabel = "login_button_label"
    static let loadingView = "loading_view"
}
