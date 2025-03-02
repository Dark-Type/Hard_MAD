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
    // MARK: - Properties
    
    let viewModel: JournalViewModel
    private var cancellables = Set<AnyCancellable>()
    var onNewEntryTapped: (@Sendable () async -> Void)?
    
    // MARK: - UI Components
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(AppFont.fancy, size: 36)
        //need other font for this, a lighter one
        label.text = L10n.Journal.title
        label.textColor = .white
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var statsContainerView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fillProportionally
        view.spacing = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var totalRecordsView = StatisticView(title: "Total Records")
    private lazy var todayRecordsView = StatisticView(title: "Today")
    private lazy var streakView = StatisticView(title: "Streak")
    
    private lazy var emotionCircleView: EmotionCircleView = {
        let view = EmotionCircleView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(JournalEntryCell.self, forCellReuseIdentifier: "JournalEntryCell")
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        table.backgroundColor = .clear
        table.estimatedRowHeight = 174
        table.rowHeight = 174
        table.prefetchDataSource = self
        table.isScrollEnabled = false
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private var tableViewHeightConstraint: NSLayoutConstraint?
    
    private var preparedCells = [IndexPath: JournalEntryCell]()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
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
        
        scrollView.delegate = self
        
        Task {
            await viewModel.initialize()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !viewModel.records.isEmpty && tableView.visibleCells.isEmpty {
            tableView.reloadData()
        }
        
        updateTableViewHeight()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .black
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        view.addSubview(loadingIndicator)
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(statsContainerView)
        statsContainerView.addArrangedSubview(totalRecordsView)
        statsContainerView.addArrangedSubview(todayRecordsView)
        statsContainerView.addArrangedSubview(streakView)
        
        contentView.addSubview(titleLabel)
        
        contentView.addSubview(emotionCircleView)
        
        contentView.addSubview(tableView)
        
        emotionCircleView.onAddButtonTapped = { [weak self] in
            Task {
                await self?.onNewEntryTapped?()
            }
        }
        
        let tableHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 200)
        tableHeightConstraint.priority = .defaultHigh
        tableViewHeightConstraint = tableHeightConstraint
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            statsContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            statsContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            statsContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            titleLabel.topAnchor.constraint(equalTo: statsContainerView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
           
            
            emotionCircleView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            emotionCircleView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emotionCircleView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9),
            
            tableView.topAnchor.constraint(equalTo: emotionCircleView.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            tableHeightConstraint,
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
    }
    
    // MARK: - Dynamic Table Height
    
    private func updateTableViewHeight() {
        let numberOfRows = tableView.numberOfRows(inSection: 0)
        if numberOfRows > 0 {
            let totalHeight = CGFloat(numberOfRows) * tableView.rowHeight
            
            if let heightConstraint = tableViewHeightConstraint,
               heightConstraint.constant != totalHeight
            {
                heightConstraint.constant = totalHeight
                
                view.layoutIfNeeded()
                scrollView.contentSize = contentView.frame.size
            }
        } else {
            tableViewHeightConstraint?.constant = 200
        }
    }
    
    // MARK: - Bindings
    
    private func setupBindings() {
        viewModel.$records
            .receive(on: DispatchQueue.main)
            .sink { [weak self] records in
                guard let self = self else { return }
                self.preparedCells.removeAll()
                self.tableView.reloadData()
                
                self.updateTableViewHeight()
                
                if !records.isEmpty {
                    self.preRenderVisibleCells()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$statistics
            .receive(on: DispatchQueue.main)
            .sink { [weak self] stats in
                guard let stats = stats else { return }
                self?.totalRecordsView.setValue(stats.totalCount)
                self?.todayRecordsView.setValue(stats.todayCount)
                self?.streakView.setValue(stats.streakDays)
            }
            .store(in: &cancellables)
        
        viewModel.$todayEmotions
            .receive(on: DispatchQueue.main)
            .sink { [weak self] emotions in
                self?.emotionCircleView.configure(with: emotions)
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
    
    // MARK: - Cell Rendering
        
    private func refreshVisibleCellGradients() {
        tableView.indexPathsForVisibleRows?.forEach { indexPath in
            if let cell = tableView.cellForRow(at: indexPath) as? JournalEntryCell,
               let record = viewModel.records[safe: indexPath.row]
            {
                DispatchQueue.main.async {
                    cell.refreshGradient(with: record)
                }
            }
        }
    }
    
    // MARK: - Cell Pre-rendering
    
    private func preRenderVisibleCells() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            
            let visibleIndexPaths = self.getEstimatedVisibleIndexPaths()
            for indexPath in visibleIndexPaths {
                if indexPath.row < self.viewModel.records.count {
                    self.prepareCell(at: indexPath)
                }
            }
            
            self.tableView.setNeedsLayout()
            self.tableView.layoutIfNeeded()
            
            self.updateTableViewHeight()
        }
    }
       
    private func prepareCell(at indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JournalEntryCell", for: indexPath) as! JournalEntryCell
        let record = viewModel.records[indexPath.row]
        cell.configure(with: record)
        
        let cellWidth = tableView.bounds.width
        cell.frame = CGRect(x: 0, y: 0, width: cellWidth, height: 174)
        
        cell.layoutIfNeeded()
        
        preparedCells[indexPath] = cell
    }
    
    private func getEstimatedVisibleIndexPaths() -> [IndexPath] {
        guard !viewModel.records.isEmpty else { return [] }
        
        let visibleCount = min(10, viewModel.records.count)
        
        return (0 ..< visibleCount).map { IndexPath(row: $0, section: 0) }
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
}

// MARK: - UITableView DataSource & Delegate

extension JournalViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = viewModel.records.count
        
        DispatchQueue.main.async { [weak self] in
            self?.updateTableViewHeight()
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let preparedCell = preparedCells[indexPath] {
            preparedCells.removeValue(forKey: indexPath)
            return preparedCell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "JournalEntryCell", for: indexPath) as! JournalEntryCell
        let record = viewModel.records[indexPath.row]
        cell.configure(with: record)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let journalCell = cell as? JournalEntryCell,
           let record = viewModel.records[safe: indexPath.row]
        {
            DispatchQueue.main.async {
                journalCell.refreshGradient(with: record)
            }
        }
    }
}

// MARK: - UITableView Prefetching

extension JournalViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if indexPath.row < viewModel.records.count && preparedCells[indexPath] == nil {
                prepareCell(at: indexPath)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            preparedCells.removeValue(forKey: indexPath)
        }
    }
}

extension JournalViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        refreshVisibleCellGradients()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            refreshVisibleCellGradients()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        refreshVisibleCellGradients()
    }
}

extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
