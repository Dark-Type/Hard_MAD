final class JournalViewController: UIViewController {
    private let viewModel: JournalViewModelProtocol
    var onEmotionScreenTapped: (() -> Void)?
    
    private lazy var emotionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Go to Emotion Screen", for: .normal)
        button.addTarget(self, action: #selector(emotionButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(viewModel: JournalViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        title = "Journal"
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(emotionButton)
        
        NSLayoutConstraint.activate([
            emotionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emotionButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func emotionButtonTapped() {
        onEmotionScreenTapped?()
    }
}