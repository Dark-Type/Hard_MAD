@MainActor
final class RecordBuilder {
    private(set) var selectedEmotion: Emotion?
    private(set) var note: String?
    
    func setEmotion(_ emotion: Emotion) {
        selectedEmotion = emotion
    }
    
    func setNote(_ note: String) {
        self.note = note
    }
    
    func build() -> JournalRecord? {
        guard let emotion = selectedEmotion,
              let note = note,
              !note.isEmpty else {
            return nil
        }
        return JournalRecord(emotion: emotion, note: note)
    }
}