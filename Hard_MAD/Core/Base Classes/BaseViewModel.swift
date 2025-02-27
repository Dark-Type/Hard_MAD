//
//  BaseViewModel.swift
//  Hard_MAD
//
//  Created by dark type on 27.02.2025.
//

import UIKit

@MainActor
class BaseViewModel {
    // MARK: - Published Properties

    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?

    // MARK: - Callbacks

    var showLoadingIndicator: ((Bool) -> Void)?
    var showError: ((String) -> Void)?

    // MARK: - Date Formatting

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter
    }()

    // MARK: - Initialization

    init() {}

    // MARK: - Lifecycle Methods

    func initialize() async {}

    func cleanup() {}

    // MARK: - Loading State Management

    func withLoading<T: Sendable>(_ operation: @MainActor @Sendable () async throws -> T) async throws -> T {
        do {
            setLoading(true)
            let result = try await operation()
            setLoading(false)
            return result
        } catch {
            setLoading(false)
            throw error
        }
    }

    private func setLoading(_ isLoading: Bool) {
        self.isLoading = isLoading
        showLoadingIndicator?(isLoading)
    }

    // MARK: - Error Handling

    func handleError(_ error: Error) {
        self.error = error
        showError?(error.localizedDescription)
    }
}
