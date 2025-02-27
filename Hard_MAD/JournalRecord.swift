struct JournalRecord: Sendable {
    let id: UUID
    let emotion: Emotion
    let note: String
    let createdAt: Date
    
    init(emotion: Emotion, note: String) {
        self.id = UUID()
        self.emotion = emotion
        self.note = note
        self.createdAt = Date()
    }
}

enum Emotion: String, CaseIterable {
    case happy = "Happy"
    case sad = "Sad"
    case angry = "Angry"
    case anxious = "Anxious"
    case peaceful = "Peaceful"
    // Add more emotions as needed
}