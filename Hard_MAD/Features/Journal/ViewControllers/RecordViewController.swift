//
//  RecordViewController.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//

import Combine
import SnapKit
import UIKit

final class RecordViewController: UIViewController {
    // MARK: - Properties
    
    let viewModel: RecordViewModel
    private var cancellables = Set<AnyCancellable>()
    var onRecordComplete: (@Sendable (JournalRecord) async -> Void)?
    
    // MARK: - UI Components
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "goBack"), for: .normal)
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.Record.title
        label.font = UIFont.appFont(AppFont.fancy, size: 24)
        label.textColor = .white
        return label
    }()
    
    private lazy var journalEntryCell: JournalEntryCell = {
        let cell = JournalEntryCell(style: .default, reuseIdentifier: nil)
        return cell
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.setContentCompressionResistancePriority(.required, for: .vertical)
        return stackView
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(L10n.Common.save, for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 20
        button.titleLabel?.font = UIFont.appFont(AppFont.regular, size: 16)
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private var questionViews: [QuestionView] = []
    
    // MARK: - Initialization
    
    init(viewModel: RecordViewModel) {
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
        
        print("RecordViewController viewDidLoad")
        
        if let emotion = viewModel.selectedEmotion {
            let tempRecord = JournalRecord(
                emotion: emotion,
                answer0: "",
                answer1: "",
                answer2: ""
            )
            journalEntryCell.configure(with: tempRecord)
        }
        
        Task {
            await viewModel.initialize()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        for questionView in questionViews {
            questionView.setNeedsLayout()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Setup
    
    private func setupBindings() {
        viewModel.$questions
            .receive(on: DispatchQueue.main)
            .sink { [weak self] questions in
                self?.setupQuestionViews(with: questions)
            }
            .store(in: &cancellables)
            
        viewModel.$answers
            .receive(on: DispatchQueue.main)
            .sink { [weak self] answers in
                self?.updateQuestionViewsWithAnswers(answers)
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
    
    private func setupUI() {
        view.backgroundColor = .black
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(backButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(journalEntryCell)
        contentView.addSubview(mainStackView)
        
        view.addSubview(saveButton)
        view.addSubview(loadingIndicator)
        
        setupAccessibilityIdentifiers()
        setupConstraints()
    }
    
    private func setupAccessibilityIdentifiers() {
        backButton.accessibilityIdentifier = "backButton"
        titleLabel.accessibilityIdentifier = "recordTitleLabel"
        journalEntryCell.accessibilityIdentifier = "journalEntryCell"
        saveButton.accessibilityIdentifier = "saveButton"
        loadingIndicator.accessibilityIdentifier = "loadingIndicator"
        mainStackView.accessibilityIdentifier = "questionsStackView"
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(saveButton.snp.top).offset(-20)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
            make.width.equalTo(scrollView)
        }
        
        backButton.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(16)
            make.leading.equalTo(contentView).offset(16)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(backButton)
            make.leading.equalTo(backButton.snp.trailing).offset(12)
        }
        
        journalEntryCell.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(16)
            make.leading.trailing.equalTo(contentView)
            make.height.equalTo(174)
        }
        
        mainStackView.snp.makeConstraints { make in
            make.top.equalTo(journalEntryCell.snp.bottom).offset(16)
            make.leading.equalTo(contentView).offset(16)
            make.trailing.equalTo(contentView).offset(-16)
            make.bottom.lessThanOrEqualTo(contentView).offset(-16)
        }
        
        saveButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalTo(48)
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    private func setupQuestionViews(with questions: [String]) {
        questionViews.forEach { $0.removeFromSuperview() }
        mainStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        questionViews = []
        
        for (index, question) in questions.enumerated() {
            let questionView = QuestionView(question: question) { [weak self] answer, isCustom in
                guard let self else { return }
                if isCustom {
                    Task {
                        await self.viewModel.addCustomAnswer(answer, forQuestion: index)
                    }
                } else {
                    self.viewModel.setAnswer(answer, forQuestion: index)
                }
            }
            questionView.tag = index
            mainStackView.addArrangedSubview(questionView)
            questionViews.append(questionView)
          
            if index < viewModel.answers.count {
                questionView.configure(with: viewModel.answers[index])
            }
        }
        
        view.setNeedsLayout()
    }

    private func updateQuestionViewsWithAnswers(_ answers: [[String]]) {
        for (index, questionView) in questionViews.enumerated() {
            if index < answers.count {
                questionView.configure(with: answers[index])
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func saveButtonTapped() {
        if let record = viewModel.buildRecord() {
            Task {
                await onRecordComplete?(record)
                navigationController?.popViewController(animated: true)
            }
        } else {
            showError(L10n.Record.Error.incompleteAnswers)
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
