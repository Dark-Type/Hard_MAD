//
//  SettingsViewController.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//

import UIKit

final class SettingsViewController: UIViewController {
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.Settings.title
        label.font = UIFont.appFont(AppFont.fancy, size: 32)
        label.textColor = .white
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 50
        imageView.backgroundColor = .systemGray5
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
   
    private let fullNameLabel: UILabel = {
        let label = UILabel()
        label.font = .appFont(AppFont.bold, size: 24)
        label.textAlignment = .center
        label.textColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let notificationContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let notificationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "notifications")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let notificationLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.Settings.Notifications.send
        label.font = UIFont.appFont(AppFont.regular, size: 16)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let notificationToggle: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
    }()
    
    private let notificationsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let addNotificationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(L10n.Settings.Notifications.add, for: .normal)
        button.titleLabel?.font = UIFont.appFont(AppFont.regular, size: 14)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 28
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let touchIDContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let touchIDImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "touch")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let touchIDLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.Settings.Login.touchID
        label.font = UIFont.appFont(AppFont.regular, size: 12)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let touchIDToggle: CustomToggleSwitch = {
        let toggle = CustomToggleSwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
    }()
    
    // MARK: - Properties
    
    private let viewModel: SettingsViewModel
    private var notifications: [NotificationTime] = []
    private var datePicker: UIDatePicker?
    
    // MARK: - Initialization
    
    init(viewModel: BaseViewModel) {
        guard let settingsViewModel = viewModel as? SettingsViewModel else {
            fatalError("SettingsViewController requires a SettingsViewModel")
        }
        self.viewModel = settingsViewModel
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
        setupActions()
        tabBarController?.tabBar.backgroundImage = UIImage()
        tabBarController?.tabBar.shadowImage = UIImage()
        Task {
            await loadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Refresh profile image every time the view appears
        loadProfileImage()
    }
      
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
 
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
      
    // MARK: - UI Setup
    
    private func setupAccessibilityIdentifiers() {
        titleLabel.accessibilityIdentifier = "settingsTitleLabel"
        profileImageView.accessibilityIdentifier = "profileImageView"
        fullNameLabel.accessibilityIdentifier = "fullNameLabel"
        
        notificationContainer.accessibilityIdentifier = "notificationContainer"
        notificationImageView.accessibilityIdentifier = "notificationImageView"
        notificationLabel.accessibilityIdentifier = "notificationLabel"
        notificationToggle.accessibilityIdentifier = "notificationToggle"
        
        notificationsStackView.accessibilityIdentifier = "notificationsStackView"
        addNotificationButton.accessibilityIdentifier = "addNotificationButton"
        
        touchIDContainer.accessibilityIdentifier = "touchIDContainer"
        touchIDImageView.accessibilityIdentifier = "touchIDImageView"
        touchIDLabel.accessibilityIdentifier = "touchIDLabel"
        touchIDToggle.accessibilityIdentifier = "touchIDToggle"
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        
        contentView.addSubview(profileImageView)
        contentView.addSubview(fullNameLabel)
        
        contentView.addSubview(notificationContainer)
        notificationContainer.addSubview(notificationImageView)
        notificationContainer.addSubview(notificationLabel)
        notificationContainer.addSubview(notificationToggle)
        
        contentView.addSubview(notificationsStackView)
        
        contentView.addSubview(addNotificationButton)

        contentView.addSubview(touchIDContainer)
        touchIDContainer.addSubview(touchIDImageView)
        touchIDContainer.addSubview(touchIDLabel)
        touchIDContainer.addSubview(touchIDToggle)
        
        setupConstraints()
        setupAccessibilityIdentifiers()
    }
    
    private func setupConstraints() {
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
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            
            profileImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),
            
            fullNameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 16),
            fullNameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            fullNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            fullNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            notificationContainer.topAnchor.constraint(equalTo: fullNameLabel.bottomAnchor, constant: 32),
            notificationContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            notificationContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            notificationContainer.heightAnchor.constraint(equalToConstant: 44),
              
            notificationImageView.leadingAnchor.constraint(equalTo: notificationContainer.leadingAnchor),
            notificationImageView.centerYAnchor.constraint(equalTo: notificationContainer.centerYAnchor),
            notificationImageView.widthAnchor.constraint(equalToConstant: 24),
            notificationImageView.heightAnchor.constraint(equalToConstant: 24),
              
            notificationLabel.leadingAnchor.constraint(equalTo: notificationImageView.trailingAnchor, constant: 16),
            notificationLabel.centerYAnchor.constraint(equalTo: notificationContainer.centerYAnchor),
              
            notificationToggle.trailingAnchor.constraint(equalTo: notificationContainer.trailingAnchor),
            notificationToggle.centerYAnchor.constraint(equalTo: notificationContainer.centerYAnchor),
              
            notificationsStackView.topAnchor.constraint(equalTo: notificationContainer.bottomAnchor, constant: 16),
            notificationsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            notificationsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
              
            addNotificationButton.topAnchor.constraint(equalTo: notificationsStackView.bottomAnchor, constant: 16),
            addNotificationButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            addNotificationButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            addNotificationButton.heightAnchor.constraint(equalToConstant: 56),
              
            touchIDContainer.topAnchor.constraint(equalTo: addNotificationButton.bottomAnchor, constant: 32),
            touchIDContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            touchIDContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            touchIDContainer.heightAnchor.constraint(equalToConstant: 44),
            touchIDContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32),
              
            touchIDImageView.leadingAnchor.constraint(equalTo: touchIDContainer.leadingAnchor),
            touchIDImageView.centerYAnchor.constraint(equalTo: touchIDContainer.centerYAnchor),
            touchIDImageView.widthAnchor.constraint(equalToConstant: 24),
            touchIDImageView.heightAnchor.constraint(equalToConstant: 24),
              
            touchIDLabel.leadingAnchor.constraint(equalTo: touchIDImageView.trailingAnchor, constant: 16),
            touchIDLabel.centerYAnchor.constraint(equalTo: touchIDContainer.centerYAnchor),
              
            touchIDToggle.trailingAnchor.constraint(equalTo: touchIDContainer.trailingAnchor),
            touchIDToggle.centerYAnchor.constraint(equalTo: touchIDContainer.centerYAnchor)
        ])
    }
      
    private func setupActions() {
        notificationToggle.addTarget(self, action: #selector(notificationToggleChanged), for: .valueChanged)
        touchIDToggle.addTarget(self, action: #selector(touchIDToggleChanged), for: .valueChanged)
        addNotificationButton.addTarget(self, action: #selector(addNotificationTapped), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        profileImageView.addGestureRecognizer(tapGesture)
    }
      
    // MARK: - Data Loading
      
    private func loadData() async {
        if let profile = viewModel.getUserProfile() {
            await MainActor.run {
                fullNameLabel.text = profile.fullName
            }
        }
        
        loadProfileImage()
          
        let isNotificationsEnabled = await viewModel.isNotificationsEnabled()
        let isTouchIDEnabled = viewModel.isTouchIDEnabled()
          
        await MainActor.run {
            notificationToggle.isOn = isNotificationsEnabled
            touchIDToggle.isOn = isTouchIDEnabled
        }
          
        await refreshNotifications()
    }
    
    private func loadProfileImage() {
        if let profile = viewModel.getUserProfile(), let profileImage = profile.image {
            profileImageView.image = profileImage
        } else {
            if let savedImage = viewModel.loadProfileImage() {
                profileImageView.image = savedImage
            } else {
                profileImageView.image = UIImage(named: "defaultProfileImage")
            }
        }
    }
      
    private func refreshNotifications() async {
        let notifications = await viewModel.getNotifications()
        await MainActor.run {
            self.notifications = notifications
            updateNotificationsStackView()
        }
    }
      
    private func updateNotificationsStackView() {
        notificationsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
          
        for notification in notifications {
            let notificationView = NotificationTimeView(notification: notification) { [weak self] notificationId in
                self?.deleteNotification(id: notificationId)
            }
            notificationView.translatesAutoresizingMaskIntoConstraints = false
            notificationsStackView.addArrangedSubview(notificationView)
              
            NSLayoutConstraint.activate([
                notificationView.leadingAnchor.constraint(equalTo: notificationsStackView.leadingAnchor),
                notificationView.trailingAnchor.constraint(equalTo: notificationsStackView.trailingAnchor)
            ])
        }
    }
      
    // MARK: - Actions
    
    @objc private func profileImageTapped() {
        showImagePicker()
    }
    
    private func showImagePicker() {
        let alertController = UIAlertController(title: "Select Profile Photo", message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alertController.addAction(UIAlertAction(title: "Take Photo", style: .default) { _ in
                self.presentImagePicker(sourceType: .camera)
            })
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alertController.addAction(UIAlertAction(title: "Choose from Library", style: .default) { _ in
                self.presentImagePicker(sourceType: .photoLibrary)
            })
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        if let popover = alertController.popoverPresentationController {
            popover.sourceView = profileImageView
            popover.sourceRect = profileImageView.bounds
        }
        
        present(alertController, animated: true)
    }
    
    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
      
    @objc func notificationToggleChanged() {
        let isCurrentlyOn = notificationToggle.isOn
        
        Task {
            await MainActor.run {
                notificationToggle.isEnabled = false
            }
            
            let success = await viewModel.setNotificationsEnabled(isCurrentlyOn)
            
            await MainActor.run {
                notificationToggle.isEnabled = true
                
                if success != isCurrentlyOn {
                    notificationToggle.isOn = success
                    
                    if isCurrentlyOn && !success {
                        showNotificationsPermissionAlert()
                    }
                }
            }
        }
    }
    
    @objc func touchIDToggleChanged() {
        let isCurrentlyOn = touchIDToggle.isOn
        
        if isCurrentlyOn && !viewModel.isBiometryAvailable() {
            touchIDToggle.isOn = false
            showBiometryNotAvailableAlert()
            return
        }
        
        Task {
            await MainActor.run {
                touchIDToggle.isEnabled = false
            }
            
            let success = await viewModel.setTouchIDEnabled(isCurrentlyOn)
            
            await MainActor.run {
                touchIDToggle.isEnabled = true
                
                if success != isCurrentlyOn {
                    touchIDToggle.isOn = success
                }
            }
        }
    }

    private func showNotificationsPermissionAlert() {
        let alert = UIAlertController(
            title: "Notifications Permission",
            message: "Please enable notifications in Settings to use this feature.",
            preferredStyle: .alert
        )
          
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
          
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
          
        present(alert, animated: true)
    }
      
    private func showBiometryNotAvailableAlert() {
        let alert = UIAlertController(
            title: "Biometric Authentication Not Available",
            message: "Your device doesn't support biometric authentication or it hasn't been set up in your device settings.",
            preferredStyle: .alert
        )
          
        alert.addAction(UIAlertAction(title: "OK", style: .default))
          
        present(alert, animated: true)
    }

    @objc private func addNotificationTapped() {
        let timePickerVC = TimePickerViewController()
        timePickerVC.delegate = self
        timePickerVC.modalPresentationStyle = .overFullScreen
        timePickerVC.modalTransitionStyle = .crossDissolve
        present(timePickerVC, animated: true)
    }
      
    @objc private func datePickerDoneButtonTapped() {
        guard let datePicker = datePicker else { return }
          
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let timeString = formatter.string(from: datePicker.date)
          
        dismiss(animated: true) {
            self.addNotification(time: timeString)
        }
    }
      
    private func addNotification(time: String) {
        Task {
            _ = await viewModel.addNotification(time: time)
            await refreshNotifications()
        }
    }
      
    private func deleteNotification(id: UUID) {
        Task {
            let success = await viewModel.removeNotification(id: id)
            if success {
                await refreshNotifications()
            }
        }
    }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate

extension SettingsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        var selectedImage: UIImage?
        
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
        }
        
        picker.dismiss(animated: true) {
            if let image = selectedImage {
                self.saveProfileImage(image)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    private func saveProfileImage(_ image: UIImage) {
        profileImageView.image = image
        
        Task {
            let success = await viewModel.saveProfileImage(image)
            if !success {
                await MainActor.run {
                    let alert = UIAlertController(
                        title: "Error",
                        message: "Failed to save profile image. Please try again.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
}

extension SettingsViewController: TimePickerViewControllerDelegate {
    func timePickerViewController(_ controller: TimePickerViewController, didSelectTime time: String) {
        addNotification(time: time)
    }
    
    func timePickerViewControllerDidCancel(_ controller: TimePickerViewController) {}
}
