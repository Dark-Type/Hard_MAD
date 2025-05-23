//
//  AnalysisViewController.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//

import Combine
import UIKit

final class AnalysisViewController: UIViewController {
    private let viewModel: AnalysisViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var weekSelector: WeekSelectorView = {
        let selector = WeekSelectorView()
        selector.delegate = self
        return selector
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        return scrollView
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.distribution = .fill
        return stack
    }()
    
    private lazy var navigationDotsView: SectionNavigationDotsView = {
        let dotsView = SectionNavigationDotsView()
        dotsView.delegate = self
        return dotsView
    }()

    private lazy var emptyStateView: EmptyStateView = {
        let view = EmptyStateView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let dailyEmotionsView = WeeklyCategoriesView()
    private let weeklyEmotionsView = WeeklyEmotionsView()
    private let frequentEmotionsView = MostFrequentEmotionsView()
    private let timeOfDayMoodView = MoodTimeOfDayView()
    
    private lazy var sectionViews: [UIView] = [
        dailyEmotionsView,
        weeklyEmotionsView,
        frequentEmotionsView,
        timeOfDayMoodView
    ]
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    init(viewModel: AnalysisViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        loadData()
    }

    func setupAccessibilityIdentifiers() {
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

    private func setupUI() {
        view.backgroundColor = .black
        
        view.addSubview(weekSelector)
        weekSelector.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(contentStackView)
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(navigationDotsView)
        navigationDotsView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(emptyStateView)
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        
        if let frequentIndex = sectionViews.firstIndex(where: { $0 === frequentEmotionsView }),
           frequentIndex < sectionViews.count - 1
        {
            contentStackView.setCustomSpacing(80, after: frequentEmotionsView)
        }
        for sectionView in sectionViews {
            contentStackView.addArrangedSubview(sectionView)
            
            switch sectionView {
                case is WeeklyEmotionsView:
                    sectionView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.frameLayoutGuide.heightAnchor, multiplier: 0.5).isActive = true
                case is MoodTimeOfDayView:
                    sectionView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.frameLayoutGuide.heightAnchor).isActive = true
                case is MoodTimeOfDayView:
                    sectionView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.frameLayoutGuide.heightAnchor).isActive = true
                default:
                    sectionView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor, multiplier: 0.8).isActive = true
            }
        }
        NSLayoutConstraint.activate([
            view.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            weekSelector.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            weekSelector.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            weekSelector.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            weekSelector.heightAnchor.constraint(equalToConstant: 30),
                                     
            scrollView.topAnchor.constraint(equalTo: weekSelector.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                                     
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32),
                                     
            navigationDotsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationDotsView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            navigationDotsView.widthAnchor.constraint(equalToConstant: 50),
            navigationDotsView.heightAnchor.constraint(equalToConstant: 150),
            
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                                     
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        setupAccessibilityIdentifiers()
    }

    private func setupBindings() {
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
        viewModel.$currentWeekData
            .receive(on: RunLoop.main)
            .sink { [weak self] weekData in
                guard let self = self, let weekData = weekData else { return }
                self.updateUI(with: weekData)
            }
            .store(in: &cancellables)
        
        viewModel.$error
            .receive(on: RunLoop.main)
            .sink { [weak self] error in
                if let error = error {
                    self?.showErrorAlert(with: error)
                }
            }
            .store(in: &cancellables)
    }
    
    private func loadData() {
        Task {
            await viewModel.initialize()
        }
    }
    
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
    
    private func scrollToSection(_ index: Int) {
        guard index >= 0 && index < sectionViews.count else { return }
        
        let sectionView = sectionViews[index]
        let sectionFrame = sectionView.convert(sectionView.bounds, to: scrollView)
        
        scrollView.setContentOffset(CGPoint(x: 0, y: sectionFrame.minY - 16), animated: true)
    }
    
    private func showErrorAlert(with error: Error) {
        let alertController = UIAlertController(
            title: "Ошибка",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        
        alertController.addAction(
            UIAlertAction(title: "OK", style: .default)
        )
        
        present(alertController, animated: true)
    }
}

// MARK: - WeekSelector Delegate

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

// MARK: - NavigationDots Delegate

extension AnalysisViewController: NavigationDotsDelegate {
    func navigationDots(_ view: SectionNavigationDotsView, didSelectSectionAt index: Int) {
        scrollToSection(index)
    }
}

// MARK: - ScrollView Delegate

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
