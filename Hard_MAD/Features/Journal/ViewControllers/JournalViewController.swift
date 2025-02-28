//
//  JournalViewController.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//

import Combine
import UIKit

@MainActor
final class JournalViewController: UIViewController {
    let viewModel: JournalViewModel
    private var cancellables = Set<AnyCancellable>()
    var onNewEntryTapped: (@Sendable () async -> Void)?
    
    // MARK: - UI Components

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(JournalEntryCell.self, forCellReuseIdentifier: "JournalEntryCell")
        table.delegate = self
        table.dataSource = self
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    // MARK: - Initialization

    init(viewModel: JournalViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        setupNavigationBar()
        
        Task {
            await viewModel.initialize()
        }
    }
    
    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: addButton)
    }
    
    // MARK: - Error Handling

    private func showError(_ message: String) {
        let alertController = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
          
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
          
        present(alertController, animated: true)
    }
      
    private func setupBindings() {
        viewModel.$records
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
          
        viewModel.showLoadingIndicator = { [weak self] isLoading in
            if isLoading {
                self?.loadingIndicator.startAnimating()
            } else {
                self?.loadingIndicator.stopAnimating()
            }
        }
          
        viewModel.showError = { [weak self] message in
            self?.showError(message)
        }
    }
    
    @objc private func addButtonTapped() {
        Task {
            await onNewEntryTapped?()
        }
    }
}

// MARK: - UITableView DataSource & Delegate

extension JournalViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.records.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JournalEntryCell", for: indexPath) as! JournalEntryCell
        let record = viewModel.records[indexPath.row]
        cell.configure(with: record)
        return cell
    }
}
