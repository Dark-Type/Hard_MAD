//
//  LaunchEnvironment.swift
//  Hard_MAD
//
//  Created by dark type on 04.03.2025.
//

import XCTest

extension XCUIApplication {
    enum LaunchEnvironment: String {
        case mockDataEnabled = "MOCK_DATA_ENABLED"
        case mockEmptyData = "MOCK_EMPTY_DATA"
    }

    func setLaunchEnvironment(_ env: LaunchEnvironment, value: String) {
        launchEnvironment[env.rawValue] = value
    }

    func enableMockData() {
        setLaunchEnvironment(.mockDataEnabled, value: "YES")
    }

    func enableEmptyMockData() {
        setLaunchEnvironment(.mockEmptyData, value: "YES")
    }
}
