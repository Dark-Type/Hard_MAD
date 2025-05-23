//
//  NotificationTimeDTO.swift
//  Hard_MAD
//
//  Created by dark type on 15.05.2025.
//

import Foundation

struct NotificationTimeDTO: Codable, Identifiable {
    let id: UUID
    let time: String
}

extension NotificationTimeDTO {
    init(from model: NotificationTime) {
        self.id = model.id
        self.time = model.time
    }
}
