//
//  WebViewController.swift
//  Hard_MAD
//
//  Created by dark type on 22.05.2025.
//

import UIKit
import WebKit

final class WebViewController: UIViewController, WKNavigationDelegate, UIAdaptivePresentationControllerDelegate {
    private let url: URL
    private let onDismiss: () -> Void
    private var webView: WKWebView!

    init(url: URL, onDismiss: @escaping () -> Void) {
        self.url = url
        self.onDismiss = onDismiss
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .formSheet
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(dismissSelf))
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        onDismiss()
    }

    private func setupWebView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view.addSubview(webView)
        webView.snp.makeConstraints { $0.edges.equalToSuperview() }
        webView.load(URLRequest(url: url))
    }

    @objc private func dismissSelf() {
        dismiss(animated: true, completion: onDismiss)
    }
}
