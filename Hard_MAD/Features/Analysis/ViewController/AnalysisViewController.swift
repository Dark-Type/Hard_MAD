//
//  AnalysisViewController.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//

import Combine
import UIKit

final class AnalysisViewController: UIViewController {
    // MARK: - Constants
    
    private enum Constants {
        static let weekSelectorHeight: CGFloat = 30
        static let contentInsets: CGFloat = 16
        static let stackViewSpacing: CGFloat = 20
        static let customSpacingAfterFrequent: CGFloat = 80
        static let navigationDotsWidth: CGFloat = 50
        static let navigationDotsHeight: CGFloat = 150
        static let weeklyEmotionsHeightMultiplier: CGFloat = 0.5
        static let defaultSectionHeightMultiplier: CGFloat = 0.8
        static let sectionScrollOffset: CGFloat = 16
    }
    
    // MARK: - Properties
    
    private let viewModel: AnalysisViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private var weekSelector: WeekSelectorView!
    private var scrollView: UIScrollView!
    private var contentStackView: UIStackView!
    private var navigationDotsView: SectionNavigationDotsView!
    private var emptyStateView: EmptyStateView!
    private var dailyEmotionsView: WeeklyCategoriesView!
    private var weeklyEmotionsView: WeeklyEmotionsView!
    private var frequentEmotionsView: MostFrequentEmotionsView!
    private var timeOfDayMoodView: MoodTimeOfDayView!
    private var activityIndicator: UIActivityIndicatorView!
    
    private var sectionViews: [UIView] {
        return [
            dailyEmotionsView,
            weeklyEmotionsView,
            frequentEmotionsView,
            timeOfDayMoodView
        ]
    }
    
    // MARK: - Initialization
    
    init(viewModel: AnalysisViewModel) {
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
        loadData()
    }
    
    // MARK: - Setup Methods
    
    private func setupViews() {
        view.backgroundColor = .black
        
        setupWeekSelector()
        setupScrollView()
        setupContentStackView()
        setupNavigationDotsView()
        setupEmptyStateView()
        setupActivityIndicator()
        setupSectionViews()
        
        addSubviews()
        configureSectionViews()
    }
    
    private func setupWeekSelector() {
        weekSelector = WeekSelectorView()
        weekSelector.delegate = self
        weekSelector.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        scrollView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupContentStackView() {
        contentStackView = UIStackView()
        contentStackView.axis = .vertical
        contentStackView.spacing = Constants.stackViewSpacing
        contentStackView.distribution = .fill
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupNavigationDotsView() {
        navigationDotsView = SectionNavigationDotsView()
        navigationDotsView.delegate = self
        navigationDotsView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupEmptyStateView() {
        emptyStateView = EmptyStateView()
        emptyStateView.isHidden = true
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupSectionViews() {
        dailyEmotionsView = WeeklyCategoriesView()
        weeklyEmotionsView = WeeklyEmotionsView()
        frequentEmotionsView = MostFrequentEmotionsView()
        timeOfDayMoodView = MoodTimeOfDayView()
    }
    
    private func addSubviews() {
        view.addSubview(weekSelector)
        view.addSubview(scrollView)
        view.addSubview(navigationDotsView)
        view.addSubview(emptyStateView)
        view.addSubview(activityIndicator)
        
        scrollView.addSubview(contentStackView)
        
        sectionViews.forEach { contentStackView.addArrangedSubview($0) }
    }
    
    private func configureSectionViews() {
        if let frequentIndex = sectionViews.firstIndex(where: { $0 === frequentEmotionsView }),
           frequentIndex < sectionViews.count - 1
        {
            contentStackView.setCustomSpacing(Constants.customSpacingAfterFrequent, after: frequentEmotionsView)
        }
    }
    
    // MARK: - Constraints
    
    private func setupConstraints() {
        setupWeekSelectorConstraints()
        setupScrollViewConstraints()
        setupContentStackViewConstraints()
        setupNavigationDotsConstraints()
        setupEmptyStateConstraints()
        setupActivityIndicatorConstraints()
        setupSectionViewsConstraints()
    }
    
    private func setupWeekSelectorConstraints() {
        weekSelector.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(Constants.weekSelectorHeight)
        }
    }
    
    private func setupScrollViewConstraints() {
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(weekSelector.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func setupContentStackViewConstraints() {
        contentStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(Constants.contentInsets)
            make.leading.trailing.equalToSuperview().inset(Constants.contentInsets)
            make.width.equalTo(scrollView.snp.width).offset(-Constants.contentInsets * 2)
        }
    }
    
    private func setupNavigationDotsConstraints() {
        navigationDotsView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(Constants.navigationDotsWidth)
            make.height.equalTo(Constants.navigationDotsHeight)
        }
    }
    
    private func setupEmptyStateConstraints() {
        emptyStateView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(Constants.contentInsets)
        }
    }
    
    private func setupActivityIndicatorConstraints() {
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setupSectionViewsConstraints() {
        for sectionView in sectionViews {
            switch sectionView {
            case is WeeklyEmotionsView:
                sectionView.snp.makeConstraints { make in
                    make.height.greaterThanOrEqualTo(scrollView.snp.height).multipliedBy(Constants.weeklyEmotionsHeightMultiplier)
                }
            case is MoodTimeOfDayView:
                sectionView.snp.makeConstraints { make in
                    make.height.greaterThanOrEqualTo(scrollView.snp.height)
                }
            default:
                sectionView.snp.makeConstraints { make in
                    make.height.equalTo(scrollView.snp.height).multipliedBy(Constants.defaultSectionHeightMultiplier)
                }
            }
        }
    }
    
    // MARK: - Accessibility
    
    private func setupAccessibilityIdentifiers() {
        weekSelector.accessibilityIdentifier = "weekSelectorView"
        scrollView.accessibilityIdentifier = "analysisScrollView"
        contentStackView.accessibilityIdentifier = "contentStackView"
        navigationDotsView.accessibilityIdentifier = "navigationDotsView"
        activityIndicator.accessibilityIdentifier = "analysisActivityIndicator"
        emptyStateView.accessibilityIdentifier = "emptyStateView"
        
        dailyEmotionsView.accessibilityIdentifier = "dailyEmotionsView"
        weeklyEmotionsView.accessibilityIdentifier = "weeklyEmotionsView"
        frequentEmotionsView.accessibilityIdentifier = "frequentEmotionsView"
        timeOfDayMoodView.accessibilityIdentifier = "timeOfDayMoodView"
    }
    
    // MARK: - Bindings
    
    private func setupBindings() {
        setupLoadingBinding()
        setupWeeksBinding()
        setupWeekDataBinding()
        setupErrorBinding()
    }
    
    private func setupLoadingBinding() {
        viewModel.$isLoading
            .receive(on: RunLoop.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.stopAnimating()
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupWeeksBinding() {
        viewModel.$weeks
            .receive(on: RunLoop.main)
            .sink { [weak self] weeks in
                guard let self = self else { return }
                let isEmpty = weeks.isEmpty
                self.emptyStateView.isHidden = !isEmpty
                self.scrollView.isHidden = isEmpty
                self.navigationDotsView.isHidden = isEmpty
            }
            .store(in: &cancellables)
        
        viewModel.$weeks
            .combineLatest(viewModel.$currentWeekIndex)
            .receive(on: RunLoop.main)
            .sink { [weak self] weeks, selectedIndex in
                guard let self = self, !weeks.isEmpty else { return }
                self.weekSelector.configure(with: weeks, selectedIndex: selectedIndex)
            }
            .store(in: &cancellables)
    }
    
    private func setupWeekDataBinding() {
        viewModel.$currentWeekData
            .receive(on: RunLoop.main)
            .sink { [weak self] weekData in
                guard let self = self, let weekData = weekData else { return }
                self.updateUI(with: weekData)
            }
            .store(in: &cancellables)
    }
    
    private func setupErrorBinding() {
        viewModel.$error
            .receive(on: RunLoop.main)
            .sink { [weak self] error in
                if let error = error {
                    self?.showErrorAlert(with: error)
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Data Loading
    
    private func loadData() {
        Task {
            await viewModel.initialize()
        }
    }
    
    // MARK: - UI Updates
    
    private func updateUI(with weekData: AnalysisWeekData) {
        var allWeekRecords: [JournalRecord] = []
        
        for (_, records) in weekData.dailyEmotions {
            allWeekRecords.append(contentsOf: records)
        }
        
        dailyEmotionsView.configure(with: allWeekRecords, forDate: Date())
        weeklyEmotionsView.configure(with: weekData.dailyEmotions)
        weeklyEmotionsView.adjustHeightBasedOnContent()
        frequentEmotionsView.configure(with: weekData.mostFrequentEmotions)
        timeOfDayMoodView.configure(with: weekData.timeOfDayMoods)
    }
    
    // MARK: - Navigation
    
    private func scrollToSection(_ index: Int) {
        guard index >= 0 && index < sectionViews.count else { return }
        
        let sectionView = sectionViews[index]
        let sectionFrame = sectionView.convert(sectionView.bounds, to: scrollView)
        
        scrollView.setContentOffset(
            CGPoint(x: 0, y: sectionFrame.minY - Constants.sectionScrollOffset),
            animated: true
        )
    }
    
    // MARK: - Error Handling
    
    private func showErrorAlert(with error: Error) {
        let alertController = UIAlertController(
            title: L10n.Error.generic,
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        
        alertController.addAction(
            UIAlertAction(title: "OK", style: .default)
        )
        
        present(alertController, animated: true)
    }
}

// MARK: - WeekSelectorDelegate

extension AnalysisViewController: WeekSelectorDelegate {
    func weekSelector(_ selector: WeekSelectorView, didSelectWeekAt index: Int) {
        weekSelector.isUserInteractionEnabled = false
        
        Task {
            await viewModel.selectWeek(at: index)
            
            await MainActor.run {
                weekSelector.isUserInteractionEnabled = true
            }
        }
    }
}

// MARK: - NavigationDotsDelegate

extension AnalysisViewController: NavigationDotsDelegate {
    func navigationDots(_ view: SectionNavigationDotsView, didSelectSectionAt index: Int) {
        scrollToSection(index)
    }
}

// MARK: - UIScrollViewDelegate

extension AnalysisViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        for (index, sectionView) in sectionViews.enumerated() {
            let sectionFrame = sectionView.convert(sectionView.bounds, to: scrollView)
            let sectionTop = sectionFrame.minY - scrollView.contentOffset.y
            let sectionBottom = sectionFrame.maxY - scrollView.contentOffset.y
            
            if sectionTop < view.bounds.height / 2 && sectionBottom > view.bounds.height / 2 {
                navigationDotsView.setSelectedSection(index, animated: true)
                break
            }
        }
    }
}
