//
//  Container.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//

final class Container {
    let authService: AuthServiceProtocol = AuthService()

    let databaseClient: DatabaseClientProtocol = DatabaseClient()

    lazy var journalService: JournalServiceProtocol = JournalService(dbClient: databaseClient)

    lazy var notificationService: NotificationServiceProtocol = NotificationService(dbClient: databaseClient)

    lazy var analysisService: AnalysisServiceProtocol = AnalysisService(dbClient: databaseClient)

    lazy var questionService: QuestionServiceProtocol = QuestionService(dbClient: databaseClient)
}
