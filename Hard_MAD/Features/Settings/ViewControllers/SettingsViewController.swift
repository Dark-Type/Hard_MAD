//
//  SettingsViewController.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//

import SnapKit
import UIKit

final class SettingsViewController: UIViewController {
    // MARK: - Constants
    
    private enum Constants {
        enum Layout {
            static let horizontalPadding: CGFloat = 24
            static let verticalSpacing: CGFloat = 16
            static let largeVerticalSpacing: CGFloat = 32
            static let mediumVerticalSpacing: CGFloat = 24
            static let stackViewSpacing: CGFloat = 12
        }
        
        enum ProfileImage {
            static let size: CGFloat = 100
            static let cornerRadius: CGFloat = 50
        }
        
        enum Container {
            static let height: CGFloat = 44
        }
        
        enum Icon {
            static let size: CGFloat = 24
        }
        
        enum Button {
            static let height: CGFloat = 56
            static let cornerRadius: CGFloat = 28
            static let iconSpacing: CGFloat = 16
        }
        
        enum FontSize {
            static let title: CGFloat = 32
            static let fullName: CGFloat = 24
            static let notification: CGFloat = 16
            static let button: CGFloat = 14
            static let touchID: CGFloat = 12
        }
    }
    
    // MARK: - UI Components
    
    private lazy var scrollView = UIScrollView()
    private lazy var contentView = UIView()
    private lazy var titleLabel = UILabel()
    private lazy var profileImageView = UIImageView()
    private lazy var fullNameLabel = UILabel()
    private lazy var notificationContainer = UIView()
    private lazy var notificationImageView = UIImageView()
    private lazy var notificationLabel = UILabel()
    private lazy var notificationToggle = UISwitch()
    private lazy var notificationsStackView = UIStackView()
    private lazy var addNotificationButton = UIButton(type: .system)
    private lazy var touchIDContainer = UIView()
    private lazy var touchIDImageView = UIImageView()
    private lazy var touchIDLabel = UILabel()
    private lazy var touchIDToggle = CustomToggleSwitch()
    
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
        configureTabBar()
        Task {
            await loadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        loadProfileImage()
    }
      
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .black
        
        setupScrollView()
        setupContentView()
        setupTitleLabel()
        setupProfileImageView()
        setupFullNameLabel()
        setupNotificationSection()
        setupNotificationsStackView()
        setupAddNotificationButton()
        setupTouchIDSection()
        
        setupConstraints()
        setupAccessibilityIdentifiers()
    }
    
    private func setupScrollView() {
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
    }
    
    private func setupContentView() {
        scrollView.addSubview(contentView)
    }
    
    private func setupTitleLabel() {
        titleLabel.text = L10n.Settings.title
        titleLabel.font = UIFont.appFont(AppFont.fancy, size: Constants.FontSize.title)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .left
        contentView.addSubview(titleLabel)
    }
    
    private func setupProfileImageView() {
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = Constants.ProfileImage.cornerRadius
        profileImageView.backgroundColor = .systemGray5
        profileImageView.isUserInteractionEnabled = true
        contentView.addSubview(profileImageView)
    }
    
    private func setupFullNameLabel() {
        fullNameLabel.font = .appFont(AppFont.bold, size: Constants.FontSize.fullName)
        fullNameLabel.textAlignment = .center
        fullNameLabel.textColor = .white
        fullNameLabel.numberOfLines = 0
        contentView.addSubview(fullNameLabel)
    }
    
    private func setupNotificationSection() {
        setupNotificationContainer()
        setupNotificationImageView()
        setupNotificationLabel()
        setupNotificationToggle()
    }
    
    private func setupNotificationContainer() {
        contentView.addSubview(notificationContainer)
    }
    
    private func setupNotificationImageView() {
        notificationImageView.image = UIImage(named: "notifications")
        notificationImageView.contentMode = .scaleAspectFit
        notificationContainer.addSubview(notificationImageView)
    }
    
    private func setupNotificationLabel() {
        notificationLabel.text = L10n.Settings.Notifications.send
        notificationLabel.font = UIFont.appFont(AppFont.regular, size: Constants.FontSize.notification)
        notificationLabel.textColor = .white
        notificationContainer.addSubview(notificationLabel)
    }
    
    private func setupNotificationToggle() {
        notificationContainer.addSubview(notificationToggle)
    }
    
    private func setupNotificationsStackView() {
        notificationsStackView.axis = .vertical
        notificationsStackView.spacing = Constants.Layout.stackViewSpacing
        notificationsStackView.distribution = .fillEqually
        contentView.addSubview(notificationsStackView)
    }
    
    private func setupAddNotificationButton() {
        addNotificationButton.setTitle(L10n.Settings.Notifications.add, for: .normal)
        addNotificationButton.titleLabel?.font = UIFont.appFont(AppFont.regular, size: Constants.FontSize.button)
        addNotificationButton.backgroundColor = .white
        addNotificationButton.setTitleColor(.black, for: .normal)
        addNotificationButton.layer.cornerRadius = Constants.Button.cornerRadius
        contentView.addSubview(addNotificationButton)
    }
    
    private func setupTouchIDSection() {
        setupTouchIDContainer()
        setupTouchIDImageView()
        setupTouchIDLabel()
        setupTouchIDToggle()
    }
    
    private func setupTouchIDContainer() {
        contentView.addSubview(touchIDContainer)
    }
    
    private func setupTouchIDImageView() {
        touchIDImageView.image = UIImage(named: "touch")
        touchIDImageView.contentMode = .scaleAspectFit
        touchIDContainer.addSubview(touchIDImageView)
    }
    
    private func setupTouchIDLabel() {
        touchIDLabel.text = L10n.Settings.Login.touchID
        touchIDLabel.font = UIFont.appFont(AppFont.regular, size: Constants.FontSize.touchID)
        touchIDLabel.textColor = .white
        touchIDContainer.addSubview(touchIDLabel)
    }
    
    private func setupTouchIDToggle() {
        touchIDContainer.addSubview(touchIDToggle)
    }
    
    private func setupConstraints() {
        setupScrollViewConstraints()
        setupContentViewConstraints()
        setupTitleLabelConstraints()
        setupProfileImageViewConstraints()
        setupFullNameLabelConstraints()
        setupNotificationSectionConstraints()
        setupNotificationsStackViewConstraints()
        setupAddNotificationButtonConstraints()
        setupTouchIDSectionConstraints()
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
            make.width.equalToSuperview()
        }
    }
    
    private func setupTitleLabelConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Constants.Layout.mediumVerticalSpacing)
            make.leading.equalToSuperview().offset(Constants.Layout.horizontalPadding)
        }
    }
    
    private func setupProfileImageViewConstraints() {
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Constants.Layout.mediumVerticalSpacing)
            make.centerX.equalToSuperview()
            make.size.equalTo(Constants.ProfileImage.size)
        }
    }
    
    private func setupFullNameLabelConstraints() {
        fullNameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(Constants.Layout.verticalSpacing)
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(Constants.Layout.horizontalPadding)
            make.trailing.equalToSuperview().offset(-Constants.Layout.horizontalPadding)
        }
    }
    
    private func setupNotificationSectionConstraints() {
        setupNotificationContainerConstraints()
        setupNotificationImageViewConstraints()
        setupNotificationLabelConstraints()
        setupNotificationToggleConstraints()
    }
    
    private func setupNotificationContainerConstraints() {
        notificationContainer.snp.makeConstraints { make in
            make.top.equalTo(fullNameLabel.snp.bottom).offset(Constants.Layout.largeVerticalSpacing)
            make.leading.equalToSuperview().offset(Constants.Layout.horizontalPadding)
            make.trailing.equalToSuperview().offset(-Constants.Layout.horizontalPadding)
            make.height.equalTo(Constants.Container.height)
        }
    }
    
    private func setupNotificationImageViewConstraints() {
        notificationImageView.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.size.equalTo(Constants.Icon.size)
        }
    }
    
    private func setupNotificationLabelConstraints() {
        notificationLabel.snp.makeConstraints { make in
            make.leading.equalTo(notificationImageView.snp.trailing).offset(Constants.Button.iconSpacing)
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupNotificationToggleConstraints() {
        notificationToggle.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()
        }
    }
    
    private func setupNotificationsStackViewConstraints() {
        notificationsStackView.snp.makeConstraints { make in
            make.top.equalTo(notificationContainer.snp.bottom).offset(Constants.Layout.verticalSpacing)
            make.leading.equalToSuperview().offset(Constants.Layout.horizontalPadding)
            make.trailing.equalToSuperview().offset(-Constants.Layout.horizontalPadding)
        }
    }
    
    private func setupAddNotificationButtonConstraints() {
        addNotificationButton.snp.makeConstraints { make in
            make.top.equalTo(notificationsStackView.snp.bottom).offset(Constants.Layout.verticalSpacing)
            make.leading.equalToSuperview().offset(Constants.Layout.horizontalPadding)
            make.trailing.equalToSuperview().offset(-Constants.Layout.horizontalPadding)
            make.height.equalTo(Constants.Button.height)
        }
    }
    
    private func setupTouchIDSectionConstraints() {
        setupTouchIDContainerConstraints()
        setupTouchIDImageViewConstraints()
        setupTouchIDLabelConstraints()
        setupTouchIDToggleConstraints()
    }
    
    private func setupTouchIDContainerConstraints() {
        touchIDContainer.snp.makeConstraints { make in
            make.top.equalTo(addNotificationButton.snp.bottom).offset(Constants.Layout.largeVerticalSpacing)
            make.leading.equalToSuperview().offset(Constants.Layout.horizontalPadding)
            make.trailing.equalToSuperview().offset(-Constants.Layout.horizontalPadding)
            make.height.equalTo(Constants.Container.height)
            make.bottom.equalToSuperview().offset(-Constants.Layout.largeVerticalSpacing)
        }
    }
    
    private func setupTouchIDImageViewConstraints() {
        touchIDImageView.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.size.equalTo(Constants.Icon.size)
        }
    }
    
    private func setupTouchIDLabelConstraints() {
        touchIDLabel.snp.makeConstraints { make in
            make.leading.equalTo(touchIDImageView.snp.trailing).offset(Constants.Button.iconSpacing)
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupTouchIDToggleConstraints() {
        touchIDToggle.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()
        }
    }
    
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
    
    private func configureTabBar() {
        tabBarController?.tabBar.backgroundImage = UIImage()
        tabBarController?.tabBar.shadowImage = UIImage()
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
            notificationsStackView.addArrangedSubview(notificationView)
        }
    }
      
    // MARK: - Actions
    
    @objc private func profileImageTapped() {
        showImagePicker()
    }
    
    private func showImagePicker() {
        let alertController = UIAlertController(title: L10n.Settings.ProfilePhoto.title, message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alertController.addAction(UIAlertAction(title: L10n.Settings.ProfilePhoto.takePhoto, style: .default) { _ in
                self.presentImagePicker(sourceType: .camera)
            })
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alertController.addAction(UIAlertAction(title: L10n.Settings.ProfilePhoto.chooseLibrary, style: .default) { _ in
                self.presentImagePicker(sourceType: .photoLibrary)
            })
        }
        
        alertController.addAction(UIAlertAction(title: L10n.Common.cancel, style: .cancel))

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
            title: L10n.Settings.Notifications.Permission.title,
            message: L10n.Settings.Notifications.Permission.message,
            preferredStyle: .alert
        )
          
        alert.addAction(UIAlertAction(title: L10n.Settings.Notifications.Permission.settings, style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
          
        alert.addAction(UIAlertAction(title: L10n.Common.cancel, style: .cancel))
          
        present(alert, animated: true)
    }
      
    private func showBiometryNotAvailableAlert() {
        let alert = UIAlertController(
            title: L10n.Settings.Biometry.Unavailable.title,
            message: L10n.Settings.Biometry.Unavailable.message,
            preferredStyle: .alert
        )
          
        alert.addAction(UIAlertAction(title: L10n.Common.ok, style: .default))
          
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
                        title: L10n.Error.generic,
                        message: L10n.Settings.ProfilePhoto.Error.saveFailed,
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: L10n.Common.ok, style: .default))
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
