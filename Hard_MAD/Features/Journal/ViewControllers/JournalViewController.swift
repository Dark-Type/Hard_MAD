//
//  JournalViewController.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//

import Combine
import SnapKit
import UIKit

final class JournalViewController: UIViewController {
    // MARK: - Constants
    
    private enum Constants {
        static let titleFontSize: CGFloat = 36
        static let contentTopOffset: CGFloat = 20
        static let statsHorizontalInsets: CGFloat = 32
        static let statsSpacing: CGFloat = 12
        static let titleHorizontalInsets: CGFloat = 20
        static let titleTopOffset: CGFloat = 20
        static let emotionCircleTopOffset: CGFloat = 24
        static let emotionCircleWidthMultiplier: CGFloat = 0.9
        static let tableViewTopOffset: CGFloat = 16
        static let emptyStateHorizontalInsets: CGFloat = 20
        static let emptyStateMinHeight: CGFloat = 200
        static let emptyStateImageSize: CGFloat = 120
        static let emptyStateImageTopOffset: CGFloat = 20
        static let emptyStateImageBottomOffset: CGFloat = 16
        static let emptyStateTextInsets: CGFloat = 20
        static let emptyStateFontSize: CGFloat = 16
        static let cellHeight: CGFloat = 174
        static let defaultTableHeight: CGFloat = 200
        static let tableContentBottomInset: CGFloat = 20
        static let cellPreRenderDelay: TimeInterval = 0.1
        static let maxVisibleCellsForPreRender: Int = 10
    }
    
    // MARK: - Properties
    
    let viewModel: JournalViewModel
    private var cancellables = Set<AnyCancellable>()
    
    var onNewEntryTapped: (@Sendable () async -> Void)?
    
    private var scrollView: UIScrollView!
    private var titleLabel: UILabel!
    private var contentView: UIView!
    private var statsContainerView: UIStackView!
    private var totalRecordsView: StatisticView!
    private var todayRecordsView: StatisticView!
    private var streakView: StatisticView!
    private var emotionCircleView: EmotionCircleView!
    private var tableView: UITableView!
    private var emptyStateView: UIView!
    private var loadingIndicator: UIActivityIndicatorView!
    
    private var tableViewHeightConstraint: NSLayoutConstraint?
    
    private var preparedCells = [IndexPath: JournalEntryCell]()
    
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
        setupViews()
        setupConstraints()
        setupBindings()
        setupAccessibilityIdentifiers()
        setupDelegates()
        
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Setup Methods
    
    private func setupViews() {
        view.backgroundColor = .black
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        setupScrollView()
        setupContentView()
        setupTitleLabel()
        setupStatsContainer()
        setupStatisticViews()
        setupEmotionCircleView()
        setupTableView()
        setupEmptyStateView()
        setupLoadingIndicator()
        
        addSubviews()
        configureTableView()
        configureEmotionCircleView()
    }
    
    private func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
    }
    
    private func setupContentView() {
        contentView = UIView()
    }
    
    private func setupTitleLabel() {
        titleLabel = UILabel()
        titleLabel.font = UIFont.appFont(AppFont.fancy, size: Constants.titleFontSize)
        titleLabel.text = L10n.Journal.title
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2
    }
    
    private func setupStatsContainer() {
        statsContainerView = UIStackView()
        statsContainerView.axis = .horizontal
        statsContainerView.distribution = .fillProportionally
        statsContainerView.spacing = Constants.statsSpacing
    }
    
    private func setupStatisticViews() {
        totalRecordsView = StatisticView(title: "Total Records")
        todayRecordsView = StatisticView(title: "Today")
        streakView = StatisticView(title: "Streak")
    }
    
    private func setupEmotionCircleView() {
        emotionCircleView = EmotionCircleView()
    }
    
    private func setupTableView() {
        tableView = UITableView()
        tableView.register(JournalEntryCell.self, forCellReuseIdentifier: "JournalEntryCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.estimatedRowHeight = Constants.cellHeight
        tableView.rowHeight = Constants.cellHeight
        tableView.isScrollEnabled = false
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Constants.tableContentBottomInset, right: 0)
    }
    
    private func setupEmptyStateView() {
        emptyStateView = createEmptyStateView()
        emptyStateView.isHidden = true
    }
    
    private func setupLoadingIndicator() {
        loadingIndicator = UIActivityIndicatorView(style: .medium)
        loadingIndicator.hidesWhenStopped = true
    }
    
    private func addSubviews() {
        view.addSubview(loadingIndicator)
        view.addSubview(scrollView)
        
        scrollView.addSubview(contentView)
        
        contentView.addSubview(statsContainerView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(emotionCircleView)
        contentView.addSubview(tableView)
        contentView.addSubview(emptyStateView)
        
        addStatisticViewsToContainer()
    }
    
    private func addStatisticViewsToContainer() {
        statsContainerView.addArrangedSubview(totalRecordsView)
        statsContainerView.addArrangedSubview(todayRecordsView)
        statsContainerView.addArrangedSubview(streakView)
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.prefetchDataSource = self
        
        let tableHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: Constants.defaultTableHeight)
        tableHeightConstraint.priority = .defaultHigh
        tableViewHeightConstraint = tableHeightConstraint
        tableViewHeightConstraint?.isActive = true
    }
    
    private func configureEmotionCircleView() {
        emotionCircleView.onAddButtonTapped = { [weak self] in
            await self?.onNewEntryTapped?()
        }
    }
    
    // MARK: - Constraints
    
    private func setupConstraints() {
        setupScrollViewConstraints()
        setupContentViewConstraints()
        setupStatsContainerConstraints()
        setupTitleLabelConstraints()
        setupEmotionCircleConstraints()
        setupTableViewConstraints()
        setupEmptyStateConstraints()
        setupLoadingIndicatorConstraints()
    }
    
    private func setupScrollViewConstraints() {
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func setupContentViewConstraints() {
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }
    }
    
    private func setupStatsContainerConstraints() {
        statsContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Constants.contentTopOffset)
            make.leading.trailing.equalToSuperview().inset(Constants.statsHorizontalInsets)
        }
    }
    
    private func setupTitleLabelConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(statsContainerView.snp.bottom).offset(Constants.titleTopOffset)
            make.leading.trailing.equalToSuperview().inset(Constants.titleHorizontalInsets)
        }
    }
    
    private func setupEmotionCircleConstraints() {
        emotionCircleView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Constants.emotionCircleTopOffset)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(Constants.emotionCircleWidthMultiplier)
        }
    }
    
    private func setupTableViewConstraints() {
        tableView.snp.makeConstraints { make in
            make.top.equalTo(emotionCircleView.snp.bottom).offset(Constants.tableViewTopOffset)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    private func setupEmptyStateConstraints() {
        emptyStateView.snp.makeConstraints { make in
            make.top.equalTo(emotionCircleView.snp.bottom).offset(Constants.tableViewTopOffset)
            make.leading.trailing.equalToSuperview().inset(Constants.emptyStateHorizontalInsets)
            make.height.greaterThanOrEqualTo(Constants.emptyStateMinHeight)
        }
    }
    
    private func setupLoadingIndicatorConstraints() {
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    // MARK: - Empty State View Creation
    
    private func createEmptyStateView() -> UIView {
        let view = UIView()
        
        let imageView = UIImageView(image: UIImage(named: "emptyJournal"))
        imageView.contentMode = .scaleAspectFit
        
        let label = UILabel()
        label.text = L10n.Journal.Empty.message
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.appFont(AppFont.regular, size: Constants.emptyStateFontSize)
        label.accessibilityIdentifier = "emptyStateLabel"
        
        view.addSubview(imageView)
        view.addSubview(label)
        
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(Constants.emptyStateImageTopOffset)
            make.size.equalTo(Constants.emptyStateImageSize)
        }
        
        label.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(Constants.emptyStateImageBottomOffset)
            make.leading.trailing.equalToSuperview().inset(Constants.emptyStateTextInsets)
            make.bottom.equalToSuperview().offset(-Constants.emptyStateTextInsets)
        }
        
        view.accessibilityIdentifier = "emptyStateView"
        return view
    }
    
    // MARK: - Delegates Setup
    
    private func setupDelegates() {
        scrollView.delegate = self
    }
    
    // MARK: - Accessibility
    
    private func setupAccessibilityIdentifiers() {
        titleLabel.accessibilityIdentifier = "journalTitleLabel"
        scrollView.accessibilityIdentifier = "journalScrollView"
        tableView.accessibilityIdentifier = "journalTableView"
        loadingIndicator.accessibilityIdentifier = "journalLoadingIndicator"
        
        totalRecordsView.accessibilityIdentifier = "totalRecordsView"
        todayRecordsView.accessibilityIdentifier = "todayRecordsView"
        streakView.accessibilityIdentifier = "streakView"
        
        emotionCircleView.accessibilityIdentifier = "emotionCircleView"
    }
    
    // MARK: - Bindings
    
    private func setupBindings() {
        setupRecordsBinding()
        setupStatisticsBinding()
        setupEmotionsBinding()
        setupViewModelCallbacks()
    }
    
    private func setupRecordsBinding() {
        viewModel.$records
            .receive(on: DispatchQueue.main)
            .sink { [weak self] records in
                guard let self = self else { return }
                self.handleRecordsUpdate(records)
            }
            .store(in: &cancellables)
    }
    
    private func setupStatisticsBinding() {
        viewModel.$statistics
            .receive(on: DispatchQueue.main)
            .sink { [weak self] stats in
                guard let stats = stats else { return }
                self?.updateStatistics(stats)
            }
            .store(in: &cancellables)
    }
    
    private func setupEmotionsBinding() {
        viewModel.$todayEmotions
            .receive(on: DispatchQueue.main)
            .sink { [weak self] emotions in
                self?.emotionCircleView.configure(with: emotions)
            }
            .store(in: &cancellables)
    }
    
    private func setupViewModelCallbacks() {
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
    
    // MARK: - Data Handling
    
    private func handleRecordsUpdate(_ records: [JournalRecord]) {
        preparedCells.removeAll()
        tableView.reloadData()
        
        updateEmptyStateVisibility(isEmpty: records.isEmpty)
        updateTableViewHeight()
        
        if !records.isEmpty {
            preRenderVisibleCells()
        }
    }
    
    private func updateStatistics(_ stats: JournalStatistics) {
        totalRecordsView.setValue(stats.totalCount)
        todayRecordsView.setValue(stats.todayCount)
        streakView.setValue(stats.streakDays)
    }
    
    private func updateEmptyStateVisibility(isEmpty: Bool) {
        emptyStateView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
    
    // MARK: - Table View Height Management
    
    private func updateTableViewHeight() {
        let numberOfRows = tableView.numberOfRows(inSection: 0)
        let newHeight = numberOfRows > 0 ? CGFloat(numberOfRows) * Constants.cellHeight : Constants.defaultTableHeight
        
        if let heightConstraint = tableViewHeightConstraint,
           heightConstraint.constant != newHeight
        {
            heightConstraint.constant = newHeight
            view.layoutIfNeeded()
            scrollView.contentSize = contentView.frame.size
        }
    }
    
    // MARK: - Cell Pre-rendering
    
    private func preRenderVisibleCells() {
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.cellPreRenderDelay) { [weak self] in
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
        cell.frame = CGRect(x: 0, y: 0, width: cellWidth, height: Constants.cellHeight)
        cell.layoutIfNeeded()
        
        preparedCells[indexPath] = cell
    }
    
    private func getEstimatedVisibleIndexPaths() -> [IndexPath] {
        guard !viewModel.records.isEmpty else { return [] }
        
        let visibleCount = min(Constants.maxVisibleCellsForPreRender, viewModel.records.count)
        return (0 ..< visibleCount).map { IndexPath(row: $0, section: 0) }
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
    
    // MARK: - Error Handling
    
    private func showError(_ message: String) {
        let alertController = UIAlertController(
            title: L10n.Error.generic,
            message: message,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: L10n.Common.ok, style: .default)
        alertController.addAction(okAction)
        
        present(alertController, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension JournalViewController: UITableViewDataSource {
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
}

// MARK: - UITableViewDelegate

extension JournalViewController: UITableViewDelegate {
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

// MARK: - UITableViewDataSourcePrefetching

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

// MARK: - UIScrollViewDelegate

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

// MARK: - Array Extension

extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
