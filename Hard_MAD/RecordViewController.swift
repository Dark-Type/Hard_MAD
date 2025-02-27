final class RecordViewController: UIViewController {
    private let viewModel: RecordViewModelProtocol
    var onJournalScreenTapped: (() -> Void)?
    
    private lazy var journalButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Go to Journal Screen", for: .normal)
        button.addTarget(self, action: #selector(journalButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(viewModel: RecordViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        title = "Record"
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(journalButton)
        
        NSLayoutConstraint.activate([
            journalButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            journalButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func journalButtonTapped() {
        onJournalScreenTapped?()
    }
}