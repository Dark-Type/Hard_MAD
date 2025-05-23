//
//  NotificationTime.swift
//  Hard_MAD
//
//  Created by dark type on 03.03.2025.
//

import Foundation

struct NotificationTime: Equatable, Sendable {
    let id: UUID
    let time: String

    init(id: UUID = UUID(), time: String) {
        self.id = id
        self.time = time
    }
}
extension NotificationTime {
    init(from dto: NotificationTimeDTO) {
        self.id = dto.id
        self.time = dto.time
    }
}
