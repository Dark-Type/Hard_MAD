//
//  RecordViewController.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//

import Combine
import UIKit

final class RecordViewController: UIViewController {
    // MARK: - Properties
    
    let viewModel: RecordViewModel
    private var cancellables = Set<AnyCancellable>()
    var onRecordComplete: (@Sendable (JournalRecord) async -> Void)?
    
    // MARK: - UI Components
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "goBack"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.Record.title
        label.font = UIFont.appFont(AppFont.fancy, size: 24)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var journalEntryCell: JournalEntryCell = {
        let cell = JournalEntryCell(style: .default, reuseIdentifier: nil)
        cell.translatesAutoresizingMaskIntoConstraints = false
        return cell
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.translatesAutoresizingMaskIntoConstraints = false
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
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
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
        
        mainStackView.axis = .vertical
        mainStackView.spacing = 24
        mainStackView.distribution = .fill
        mainStackView.alignment = .fill
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -20),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            backButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 12),
            
            journalEntryCell.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 16),
            journalEntryCell.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            journalEntryCell.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            journalEntryCell.heightAnchor.constraint(equalToConstant: 174),
            
            mainStackView.topAnchor.constraint(equalTo: journalEntryCell.bottomAnchor, constant: 16),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16),
            
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            saveButton.heightAnchor.constraint(equalToConstant: 48),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupQuestionViews(with questions: [String]) {
        questionViews.forEach { $0.removeFromSuperview() }
        mainStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        questionViews = []
        
        for (index, question) in questions.enumerated() {
            let questionView = QuestionView(question: question) { [weak self] answer in
                self?.viewModel.setAnswer(answer, forQuestion: index)
            }
            
            questionView.translatesAutoresizingMaskIntoConstraints = false
            
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
            showError("Please answer all questions to save your journal entry.")
        }
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
