//
//  BiometryViewController.swift
//  Hard_MAD
//
//  Created by dark type on 22.05.2025.
//

import LocalAuthentication
import UIKit

final class BiometryViewController: UIViewController {
    private let reason: String
    private var attempt = 0
    private let maxAttempts = 3
    private let onSuccess: () -> Void
    private let onFailure: () -> Void

    private let statusLabel = UILabel()

    init(reason: String, onSuccess: @escaping () -> Void, onFailure: @escaping () -> Void) {
        self.reason = reason
        self.onSuccess = onSuccess
        self.onFailure = onFailure
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .formSheet
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        setupStatusLabel()
        attemptBiometry()
    }

    private func setupStatusLabel() {
        statusLabel.text = L10n.Biometry.loginPrompt
        statusLabel.numberOfLines = 0
        statusLabel.textAlignment = .center
        view.addSubview(statusLabel)
        statusLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.left.right.equalToSuperview().inset(36)
        }
    }

    private func attemptBiometry() {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            statusLabel.text = L10n.Biometry.unavailable
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                self?.onFailure()
            }
            return
        }

        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, _ in
            DispatchQueue.main.async {
                guard let self else { return }
                if success {
                    self.statusLabel.text = L10n.Biometry.success
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { self.onSuccess() }
                } else {
                    self.attempt += 1
                    if self.attempt < self.maxAttempts {
                        self.statusLabel.text = L10n.Biometry.tryAgain(self.maxAttempts - self.attempt)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { self.attemptBiometry() }
                    } else {
                        self.statusLabel.text = L10n.Biometry.failed
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { self.onFailure() }
                    }
                }
            }
        }
    }
}
