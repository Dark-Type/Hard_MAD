final class EmotionViewController: UIViewController {
    private let viewModel: EmotionViewModelProtocol
    var onRecordScreenTapped: (() -> Void)?
    
    private lazy var recordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Go to Record Screen", for: .normal)
        button.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(viewModel: EmotionViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        title = "Emotion"
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(recordButton)
        
        NSLayoutConstraint.activate([
            recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recordButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func recordButtonTapped() {
        onRecordScreenTapped?()
    }
}