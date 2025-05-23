//
//  UITestingCoordinator.swift
//  Hard_MAD
//
//  Created by dark type on 04.03.2025.
//

import UIKit

//final class UITestingCoordinator: BaseCoordinator {
//    private let window: UIWindow
//    private var tabBarController: UITabBarController?
//    private var journalNavigationController: UINavigationController?
//    private var analysisNavigationController: UINavigationController?
//    private var settingsNavigationController: UINavigationController?
//    init(window: UIWindow, container: Container) {
//        let navigationController = UINavigationController()
//        self.window = window
//        super.init(navigationController: navigationController, container: container)
//    }
//    
//    override func start() async {
//        await configureServices()
//        
//        if CommandLine.arguments.contains("--directToRecord") {
//            await showRecordScreen()
//        } else if CommandLine.arguments.contains("--directToEmotion") {
//            await showEmotionScreen()
//        } else if CommandLine.arguments.contains("--directToJournal") {
//            await showJournalScreen()
//        } else if CommandLine.arguments.contains("--directToAnalysis") {
//            await showAnalysisScreen()
//        } else if CommandLine.arguments.contains("--directToSettings") {
//            await showSettingsScreen()
//        } else {
//            await showLoginScreen()
//        }
//    
//        window.rootViewController = navigationController
//        window.makeKeyAndVisible()
//    }
//
//    private func setupTabBar() -> UITabBarController {
//        let tabBarController = UITabBarController()
//        journalNavigationController = UINavigationController()
//        analysisNavigationController = UINavigationController()
//        settingsNavigationController = UINavigationController()
//        
//        journalNavigationController?.tabBarItem = UITabBarItem(
//            title: "Journal",
//            image: UIImage(named: "journalTabBar") ?? UIImage(systemName: "book"),
//            selectedImage: UIImage(named: "journalTabBar") ?? UIImage(systemName: "book.fill")
//        )
//        journalNavigationController?.tabBarItem.accessibilityIdentifier = "journalTab"
//        
//        analysisNavigationController?.tabBarItem = UITabBarItem(
//            title: "Analysis",
//            image: UIImage(named: "statsTabBar") ?? UIImage(systemName: "chart.bar"),
//            selectedImage: UIImage(named: "statsTabBar") ?? UIImage(systemName: "chart.bar.fill")
//        )
//        analysisNavigationController?.tabBarItem.accessibilityIdentifier = "analysisTab"
//        
//        settingsNavigationController?.tabBarItem = UITabBarItem(
//            title: "Settings",
//            image: UIImage(named: "settingsTabBar") ?? UIImage(systemName: "gear"),
//            selectedImage: UIImage(named: "settingsTabBar") ?? UIImage(systemName: "gear")
//        )
//        settingsNavigationController?.tabBarItem.accessibilityIdentifier = "settingsTab"
//        
//        tabBarController.setViewControllers(
//            [
//                journalNavigationController!,
//                analysisNavigationController!,
//                settingsNavigationController!
//            ],
//            animated: false
//        )
//        
//        let tabBar = tabBarController.tabBar
//        tabBar.tintColor = .white
//        tabBar.unselectedItemTintColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
//        tabBar.frame.size.height = 49
//        tabBar.backgroundColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
//        
//        return tabBarController
//    }
//    
//    private func configureServices() async {
//        let mockAuthService = MockAuthService()
//        let mockQuestionService = MockQuestionService()
//        let mockJournalService = MockJournalService()
//        let mockAnalysisService = MockAnalysisService()
//        let mockNotificationService = MockNotificationService()
//        
//        if let longUserName = ProcessInfo.processInfo.environment["UI_TEST_LONG_USER_NAME"] {
//            UserDefaults.standard.set(longUserName, forKey: "testUserFullName")
//        }
//        let successString = ProcessInfo.processInfo.environment["UI_TEST_LOGIN_SUCCESS"]
//        let errorString = ProcessInfo.processInfo.environment["UI_TEST_LOGIN_ERROR"]
//        let shouldSucceed = successString == "true"
//        let shouldShowError = errorString == "true"
//        await mockAuthService.configureForUITesting(shouldSucceed: shouldSucceed, shouldShowError: shouldShowError)
//        
//        await mockQuestionService.configureForUITesting()
//        await mockJournalService.configureForUITesting()
//        await mockAnalysisService.configureForUITesting()
//        
//        await container.register(AuthServiceProtocol.self, dependency: mockAuthService)
//        await container.register(QuestionServiceProtocol.self, dependency: mockQuestionService)
//        await container.register(JournalServiceProtocol.self, dependency: mockJournalService)
//        await container.register(NotificationServiceProtocol.self, dependency: mockNotificationService)
//        await container.register(AnalysisServiceProtocol.self, dependency: mockAnalysisService)
//        
//        let factoryProvider = FactoryProvider(container: container)
//        await container.register(FactoryProvider.self, dependency: factoryProvider)
//    }
//    
//    private func showLoginScreen() async {
//        let factory = factoryProvider.getLoginViewModelFactory()
//        let viewModel = await factory.makeViewModel()
//        
//        viewModel.onLoginSuccess = { [weak self] in
//            Task { @MainActor [weak self] in
//                await self?.handleLoginSuccess()
//            }
//        }
//        
//        let loginVC = AuthViewController(viewModel: viewModel)
//        navigationController.setViewControllers([loginVC], animated: false)
//    }
//    
//    private func handleLoginSuccess() async {
//        tabBarController = setupTabBar()
//        
//        await setupJournalTab()
//        await setupAnalysisScreen()
//        await setupSettingsScreen()
//        
//        tabBarController?.selectedIndex = 0
//        
//        navigationController.setViewControllers([tabBarController!], animated: false)
//        navigationController.setNavigationBarHidden(true, animated: false)
//    }
//
//    private func showEmotionScreen() async {
//        let recordBuilder = RecordBuilder()
//        
//        if let emotionName = ProcessInfo.processInfo.environment["UI_TEST_EMOTION_NAME"] {
//            if let emotion = mapStringToEmotion(emotionName) {
//                recordBuilder.setEmotion(emotion)
//            }
//        }
//        
//        let viewController = EmotionViewController(recordBuilder: recordBuilder)
//        
//        viewController.onEmotionSelected = { [weak self] in
//            print("🧪 Emotion selected in UI test")
//            Task { @MainActor [weak self] in
//                guard let self = self else { return }
//                await self.navigateToRecordScreen(recordBuilder: recordBuilder)
//            }
//        }
//        
//        navigationController.setViewControllers([viewController], animated: false)
//    }
//
//    private func showRecordScreen() async {
//        let recordBuilder = RecordBuilder()
//           
//        if let emotionName = ProcessInfo.processInfo.environment["UI_TEST_RECORD_EMOTION"],
//           !emotionName.isEmpty,
//           let emotion = mapStringToEmotion(emotionName)
//        {
//            recordBuilder.setEmotion(emotion)
//        } else {
//            recordBuilder.setEmotion(.happy)
//        }
//           
//        let emotionVC = EmotionViewController(recordBuilder: recordBuilder)
//           
//        let questionService = await container.resolve() as QuestionServiceProtocol
//        let viewModel = RecordViewModel(
//            recordBuilder: recordBuilder,
//            questionService: questionService
//        )
//           
//        let recordVC = RecordViewController(viewModel: viewModel)
//           
//        recordVC.onRecordComplete = { [weak self] record in
//            print("🧪 Record completed in UI test")
//            
//            Task { @MainActor [weak self] in
//                guard let self = self else { return }
//                await self.showJournalScreen()
//                   
//                if let journalVC = self.navigationController.viewControllers.first as? JournalViewController {
//                    await journalVC.viewModel.addNewRecord(record)
//                }
//            }
//        }
//           
//        emotionVC.onEmotionSelected = {
//            print("🧪 Emotion selected in UI test")
//        }
//           
//        navigationController.setViewControllers([emotionVC, recordVC], animated: false)
//    }
//
//    private func navigateToEmotionScreen() async {
//        let recordBuilder = RecordBuilder()
//        
//        let viewController = EmotionViewController(recordBuilder: recordBuilder)
//        viewController.onEmotionSelected = { [weak self] in
//            print("🧪 Emotion selected in UI test")
//            Task { [weak self] in
//                await self?.navigateToRecordScreen(recordBuilder: recordBuilder)
//            }
//        }
//        
//        await MainActor.run {
//            viewController.hidesBottomBarWhenPushed = true
//            
//            if let journalNav = self.journalNavigationController, self.tabBarController != nil {
//                journalNav.pushViewController(viewController, animated: true)
//            } else {
//                self.navigationController.pushViewController(viewController, animated: true)
//            }
//        }
//    }
//
//    private func navigateToRecordScreen(recordBuilder: RecordBuilder) async {
//        let questionService = await container.resolve() as QuestionServiceProtocol
//            
//        let viewModel = RecordViewModel(
//            recordBuilder: recordBuilder,
//            questionService: questionService
//        )
//            
//        let recordVC = RecordViewController(viewModel: viewModel)
//        recordVC.hidesBottomBarWhenPushed = true
//            
//        recordVC.onRecordComplete = { [weak self] record in
//            print("🧪 Record completed in UI test")
//                
//            Task { @MainActor [weak self] in
//                guard let self = self else { return }
//                
//                if let journalNav = self.journalNavigationController, self.tabBarController != nil {
//                    journalNav.popToRootViewController(animated: true)
//                    
//                    if let journalVC = journalNav.viewControllers.first as? JournalViewController {
//                        await journalVC.viewModel.addNewRecord(record)
//                    }
//                    
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
//                        self?.tabBarController?.selectedIndex = 1
//                    }
//                } else {
//                    self.navigationController.popToRootViewController(animated: false)
//                    await self.showJournalScreen()
//                    
//                    if let journalVC = self.navigationController.viewControllers.first as? JournalViewController {
//                        await journalVC.viewModel.addNewRecord(record)
//                    }
//                }
//            }
//        }
//            
//        await MainActor.run {
//            if let journalNav = self.journalNavigationController, self.tabBarController != nil {
//                journalNav.pushViewController(recordVC, animated: true)
//            } else {
//                self.navigationController.pushViewController(recordVC, animated: true)
//            }
//        }
//    }
//
//    private func showJournalScreen() async {
//        if tabBarController == nil {
//            tabBarController = setupTabBar()
//        }
//        
//        let journalService = await container.resolve() as JournalServiceProtocol
//        
//        let viewModel = JournalViewModel(journalService: journalService)
//        
//        let viewController = JournalViewController(viewModel: viewModel)
//        
//        viewController.onNewEntryTapped = { [weak self] in
//            print("🧪 New entry tapped in UI test")
//            Task { [weak self] in
//                await self?.navigateToEmotionScreen()
//            }
//        }
//        
//        journalNavigationController?.setViewControllers([viewController], animated: false)
//        
//        if analysisNavigationController?.viewControllers.isEmpty == true {
//            await setupAnalysisScreen()
//        }
//        
//        if settingsNavigationController?.viewControllers.isEmpty == true {
//            await setupSettingsScreen()
//        }
//        
//        tabBarController?.selectedIndex = 0
//        navigationController.setViewControllers([tabBarController!], animated: false)
//        navigationController.setNavigationBarHidden(true, animated: false)
//    }
//    
//    private func showAnalysisScreen() async {
//        if tabBarController == nil {
//            tabBarController = setupTabBar()
//        }
//        
//        await setupAnalysisScreen()
//        
//        if journalNavigationController?.viewControllers.isEmpty == true {
//            await setupJournalTab()
//        }
//        
//        if settingsNavigationController?.viewControllers.isEmpty == true {
//            await setupSettingsScreen()
//        }
//        
//        tabBarController?.selectedIndex = 1
//        
//        navigationController.setViewControllers([tabBarController!], animated: false)
//        navigationController.setNavigationBarHidden(true, animated: false)
//    }
//
//    private func setupAnalysisScreen() async {
//        let analysisService = await container.resolve() as AnalysisServiceProtocol
//        
//        if let mockService = analysisService as? MockAnalysisService {
//            if ProcessInfo.processInfo.environment["UI_TEST_EMPTY_ANALYSIS"] == "true" {
//                await mockService.configureForUITesting(empty: true)
//            } else {
//                await mockService.configureForUITesting(empty: false)
//            }
//        }
//        
//        let factory = factoryProvider.getAnalysisViewModelFactory()
//        let viewModel = await factory.makeViewModel()
//        
//        let viewController = AnalysisViewController(viewModel: viewModel)
//        analysisNavigationController?.setViewControllers([viewController], animated: false)
//    }
//
//    private func setupJournalTab() async {
//        let journalService = await container.resolve() as JournalServiceProtocol
//        
//        let viewModel = JournalViewModel(journalService: journalService)
//        
//        let viewController = JournalViewController(viewModel: viewModel)
//        
//        viewController.onNewEntryTapped = { [weak self] in
//            print("🧪 New entry tapped in UI test")
//            Task { [weak self] in
//                await self?.navigateToEmotionScreen()
//            }
//        }
//
//        journalNavigationController?.setViewControllers([viewController], animated: false)
//    }
//    
//    private func showSettingsScreen() async {
//        if tabBarController == nil {
//            tabBarController = setupTabBar()
//        }
//        
//        await setupSettingsScreen()
//        
//        if journalNavigationController?.viewControllers.isEmpty == true {
//            await setupJournalTab()
//        }
//        
//        if analysisNavigationController?.viewControllers.isEmpty == true {
//            await setupAnalysisScreen()
//        }
//        
//        tabBarController?.selectedIndex = 2
//        
//        navigationController.setViewControllers([tabBarController!], animated: false)
//        navigationController.setNavigationBarHidden(true, animated: false)
//    }
//
//    private func setupSettingsScreen() async {
//        let authService = await container.resolve() as AuthServiceProtocol
//        let notificationService = await container.resolve() as NotificationServiceProtocol
//        
//        if let mockAuthService = authService as? MockAuthService {
//            await mockAuthService.configureForUITesting()
//        }
//        
//        if let mockNotificationService = notificationService as? MockNotificationService {
//            await mockNotificationService.configureForUITesting()
//        }
//        
//        let factory = factoryProvider.getSettingsViewModelFactory()
//        let viewModel = await factory.makeViewModel()
//        
//        let viewController = SettingsViewController(viewModel: viewModel)
//        
//        settingsNavigationController?.setViewControllers([viewController], animated: false)
//    }
//    
//    private func mapStringToEmotion(_ name: String) -> Emotion? {
//        let lowercaseName = name.lowercased()
//            
//        if let emotion = Emotion.allCases.first(where: { $0.rawValue.lowercased() == lowercaseName }) {
//            return emotion
//        }
//            
//        switch lowercaseName {
//        case "burnout": return .burnout
//        case "chill": return .chill
//        case "productivity": return .productivity
//        case "anxious": return .anxious
//        case "happy": return .happy
//        case "tired": return .tired
//        default: return nil
//        }
//    }
//}
