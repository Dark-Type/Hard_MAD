//
//  DatabaseClient.swift
//  Hard_MAD
//
//  Created by dark type on 23.05.2025.
//

import CoreData
import Foundation

final actor DatabaseClient: DatabaseClientProtocol {
    private let coreDataStack: CoreDataStack
    private var isSeeded = false
    
    init() {
        coreDataStack = CoreDataStack()
    }
    
    // MARK: - Private Helpers
    
    private func performInBackground<T: Sendable>(_ block: @Sendable @escaping (NSManagedObjectContext) throws -> T) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            
            let context = coreDataStack.newBackgroundContext()
            
            context.perform {
                do {
                    let result = try block(context)
                    
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func performInBackgroundWithoutResult(_ block: @Sendable @escaping (NSManagedObjectContext) throws -> Void) async throws {
        try await performInBackground { context in
            try block(context)
            return ()
        }
    }
    
    private func seedDefaultAnswersIfNeeded() async throws {
        if isSeeded {
            return
        }
        
        let hasData = try await performInBackground { context in
            let request: NSFetchRequest<QuestionAnswerEntity> = QuestionAnswerEntity.fetchRequest()
            request.fetchLimit = 1
            
            do {
                let results = try context.fetch(request)
                let hasData = !results.isEmpty

                return hasData
            } catch {
                return false
            }
        }
        
        if !hasData {
            try await seedDefaultAnswers()
        } else {}
        isSeeded = true
    }
    
    private func seedDefaultAnswers() async throws {
        let defaultAnswers: [Int: [String]] = [
            0: ["Прием пищи", "Встреча с друзьями", "Тренировка", "Хобби", "Отдых", "Поездка"],
            1: ["Один", "Друзья", "Семья", "Коллеги", "Партнер", "Питомцы"],
            2: ["Дом", "Работа", "Школа", "Транспорт", "Улица"]
        ]
        
        try await performInBackgroundWithoutResult { context in
            
            for (questionIndex, answers) in defaultAnswers {
                for answer in answers {
                    let entity = QuestionAnswerEntity(context: context)
                    entity.id = UUID()
                    entity.questionIndex = Int32(questionIndex)
                    entity.answer = answer
                }
            }
            
            try context.save()
        }
    }
    
    // MARK: - Question Answers
    
    func fetchQuestionAnswers(forQuestion index: Int) async throws -> [String] {
        try await seedDefaultAnswersIfNeeded()
       
        let answers = try await performInBackground { context in
            
            let request: NSFetchRequest<QuestionAnswerEntity> = QuestionAnswerEntity.fetchRequest()
            request.predicate = NSPredicate(format: "questionIndex == %d", index)
            request.sortDescriptors = [NSSortDescriptor(key: "answer", ascending: true)]
            
            let entities = try context.fetch(request)
            
            var answers: [String] = []
            for entity in entities {
                if let answer = entity.answer {
                    answers.append(answer)
                } else {
                    print("Found entity with nil answer for question \(index)")
                }
            }
            
            return answers
        }
        
        return answers
    }
    
    func addQuestionAnswer(_ answer: String, forQuestion index: Int) async throws {
        try await seedDefaultAnswersIfNeeded()
        
        try await performInBackgroundWithoutResult { context in
            let request: NSFetchRequest<QuestionAnswerEntity> = QuestionAnswerEntity.fetchRequest()
            request.predicate = NSPredicate(format: "questionIndex == %d AND answer == %@", index, answer)
            request.fetchLimit = 1
            
            let existingEntities = try context.fetch(request)
            
            if existingEntities.isEmpty {
                let entity = QuestionAnswerEntity(context: context)
                entity.id = UUID()
                entity.questionIndex = Int32(index)
                entity.answer = answer
                
                try context.save()
            }
        }
    }
    
    func deleteQuestionAnswer(_ answer: String, forQuestion index: Int) async throws {
        try await performInBackgroundWithoutResult { context in
            let request: NSFetchRequest<QuestionAnswerEntity> = QuestionAnswerEntity.fetchRequest()
            request.predicate = NSPredicate(format: "questionIndex == %d AND answer == %@", index, answer)
            
            let entities = try context.fetch(request)
            for entity in entities {
                context.delete(entity)
            }
            
            try context.save()
        }
    }
    
    // MARK: - Journal Records 
    
    func fetchJournalRecords(sorted: JournalSortOrder?) async throws -> [JournalRecordDTO] {
        return try await performInBackground { context in
            let request: NSFetchRequest<JournalRecordEntity> = JournalRecordEntity.fetchRequest()
            
            request.fetchBatchSize = 100
            
            if let sortOrder = sorted {
                switch sortOrder {
                case .byDateAscending:
                    request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
                case .byDateDescending:
                    request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
                }
            }
            
            let entities = try context.fetch(request)
            return entities.compactMap { entity in
                guard let id = entity.id,
                      let emotionRaw = entity.emotionRaw,
                      let createdAt = entity.createdAt
                else {
                    return nil
                }
                
                return JournalRecordDTO(
                    id: id,
                    emotionRaw: emotionRaw,
                    answer0: entity.answer0 ?? "",
                    answer1: entity.answer1 ?? "",
                    answer2: entity.answer2 ?? "",
                    createdAt: createdAt
                )
            }
        }
    }
    
    func fetchJournalRecord(id: UUID) async throws -> JournalRecordDTO? {
        return try await performInBackground { context in
            let request: NSFetchRequest<JournalRecordEntity> = JournalRecordEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1
            
            guard let entity = try context.fetch(request).first,
                  let entityId = entity.id,
                  let emotionRaw = entity.emotionRaw,
                  let createdAt = entity.createdAt
            else {
                return nil
            }
            
            return JournalRecordDTO(
                id: entityId,
                emotionRaw: emotionRaw,
                answer0: entity.answer0 ?? "",
                answer1: entity.answer1 ?? "",
                answer2: entity.answer2 ?? "",
                createdAt: createdAt
            )
        }
    }
    
    func saveJournalRecord(_ record: JournalRecordDTO) async throws {
        try await performInBackgroundWithoutResult { context in
            let request: NSFetchRequest<JournalRecordEntity> = JournalRecordEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", record.id as CVarArg)
            request.fetchLimit = 1
            
            let entity = try context.fetch(request).first ?? JournalRecordEntity(context: context)
            
            entity.id = record.id
            entity.emotionRaw = record.emotionRaw
            entity.answer0 = record.answer0
            entity.answer1 = record.answer1
            entity.answer2 = record.answer2
            entity.createdAt = record.createdAt
            
            try context.save()
        }
    }
    
    func deleteJournalRecord(id: UUID) async throws {
        try await performInBackgroundWithoutResult { context in
            let request: NSFetchRequest<JournalRecordEntity> = JournalRecordEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            
            let entities = try context.fetch(request)
            for entity in entities {
                context.delete(entity)
            }
            
            try context.save()
        }
    }
    
    func deleteAllJournalRecords() async throws {
        try await performInBackgroundWithoutResult { context in
            let request: NSFetchRequest<NSFetchRequestResult> = JournalRecordEntity.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            try context.execute(deleteRequest)
            try context.save()
        }
    }
    
    // MARK: - Notifications
    
    func fetchNotificationTimes() async throws -> [NotificationTimeDTO] {
        return try await performInBackground { context in
            let request: NSFetchRequest<NotificationTimeEntity> = NotificationTimeEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "time", ascending: true)]
            
            let entities = try context.fetch(request)
            return entities.compactMap { entity in
                guard let id = entity.id, let time = entity.time else { return nil }
                return NotificationTimeDTO(id: id, time: time)
            }
        }
    }
    
    func fetchNotificationTime(id: UUID) async throws -> NotificationTimeDTO? {
        return try await performInBackground { context in
            let request: NSFetchRequest<NotificationTimeEntity> = NotificationTimeEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1
            
            guard let entity = try context.fetch(request).first,
                  let entityId = entity.id,
                  let time = entity.time
            else {
                return nil
            }
            
            return NotificationTimeDTO(id: entityId, time: time)
        }
    }
    
    func saveNotificationTime(_ notification: NotificationTimeDTO) async throws {
        try await performInBackgroundWithoutResult { context in
            let request: NSFetchRequest<NotificationTimeEntity> = NotificationTimeEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", notification.id as CVarArg)
            request.fetchLimit = 1
            
            let entity = try context.fetch(request).first ?? NotificationTimeEntity(context: context)
            
            entity.id = notification.id
            entity.time = notification.time
            
            try context.save()
        }
    }
    
    func deleteNotificationTime(id: UUID) async throws {
        try await performInBackgroundWithoutResult { context in
            let request: NSFetchRequest<NotificationTimeEntity> = NotificationTimeEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            
            let entities = try context.fetch(request)
            for entity in entities {
                context.delete(entity)
            }
            
            try context.save()
        }
    }
    
    func deleteAllNotificationTimes() async throws {
        try await performInBackgroundWithoutResult { context in
            let request: NSFetchRequest<NSFetchRequestResult> = NotificationTimeEntity.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            try context.execute(deleteRequest)
            try context.save()
        }
    }
}

enum DatabaseError: Error {
    case unexpectedError
    case contextSaveError
    case entityNotFound
}
